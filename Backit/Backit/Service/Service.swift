/**
 Provides ability to make requests.
 
 License: MIT
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Alamofire
import BrightFutures
import Foundation

enum ServiceError: Error {
    case unknown(Error?)
    case noURLForEnvironment(Environment)
    case invalidURLForEnvironment(Environment)
    case emptyResponse
    case failedToDecode
    case noInternetConnection
    case server(Error)
}

struct ServiceResult {
    var data: Data?
    var error: Error?
}

extension ServiceResult {
    static func make(from response: DataResponse<Any>) -> ServiceResult {
        return ServiceResult(data: response.data, error: response.error)
    }
}

class Service {
    let environment: Environment
    let plugins: [ServicePlugin]
    
    let urlRequestFactory = URLRequestFactory()
    let decoder = JSONDecoder()
    
    init(environment: Environment, plugins: [ServicePlugin] = []) {
        self.environment = environment
        self.plugins = plugins
    }
    
    func request<T: ServiceEndpoint>(_ request: T) -> Future<T.ResponseType, ServiceError> {
        var urlRequest: URLRequest
        do {
            urlRequest = try urlRequestFactory.make(from: request, in: environment)
        }
        catch let error as ServiceError {
            return Future(error: error)
        }
        catch {
            return Future(error: .unknown(error))
        }

        urlRequest = plugins.reduce(urlRequest, { (urlRequest, plugin) -> URLRequest in
            return plugin.willSendRequest(urlRequest)
        })
        
        let promise = Promise<T.ResponseType, ServiceError>()
        Alamofire.request(urlRequest).responseJSON { [weak self] (response) in
            guard let self = self else {
                promise.failure(.unknown(nil))
                return
            }
            
            let result = self.plugins.reduce(ServiceResult.make(from: response), { (response, plugin) -> ServiceResult in
                return plugin.didReceiveResponse(response)
            })
            
            if let error = result.error as? URLError {
                switch error.code.rawValue {
                case -1009:
                    promise.failure(.noInternetConnection)
                default:
                    promise.failure(.server(error))
                }
                return
            }
            if let error = result.error {
                promise.failure(.unknown(error))
                return
            }
            guard let data = result.data else {
                promise.failure(.emptyResponse)
                return
            }
            guard let decodedResponse = try? self.decoder.decode(T.ResponseType.self, from: data) else {
                promise.failure(.failedToDecode)
                return
            }
            
            promise.success(decodedResponse)
        }
        
        plugins.forEach { (plugin) in
            plugin.didSendRequest(urlRequest)
        }
        
        return promise.future
    }
}
