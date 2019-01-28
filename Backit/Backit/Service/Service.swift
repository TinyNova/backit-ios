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

class Service {
    let environment: Environment
    
    let urlRequestFactory = URLRequestFactory()
    let decoder = JSONDecoder()
    
    init(environment: Environment) {
        self.environment = environment
    }
    
    func request<T: ServiceEndpoint>(_ request: T) -> Future<T.ResponseType, ServiceError> {
        let urlRequest: URLRequest
        do {
            urlRequest = try urlRequestFactory.make(from: request, in: environment)
        }
        catch let error as ServiceError {
            return Future(error: error)
        }
        catch {
            return Future(error: .unknown(error))
        }

        let promise = Promise<T.ResponseType, ServiceError>()
        Alamofire.request(urlRequest).responseJSON { [weak decoder] (response) in
            if let error = response.result.error as? URLError {
                switch error.code.rawValue {
                case -1009:
                    promise.failure(.noInternetConnection)
                default:
                    promise.failure(.server(error))
                }
                return
            }
            if let error = response.result.error {
                promise.failure(.unknown(error))
                return
            }
            guard let decoder = decoder else {
                promise.failure(.unknown(nil))
                return
            }
            guard let data = response.data else {
                promise.failure(.emptyResponse)
                return
            }
            guard let decodedResponse = try? decoder.decode(T.ResponseType.self, from: data) else {
                promise.failure(.failedToDecode)
                return
            }
            
            promise.success(decodedResponse)
        }
        
        return promise.future
    }
}
