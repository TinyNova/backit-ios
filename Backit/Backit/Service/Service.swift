/**
 Provides ability to make requests.
 
 License: MIT
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import BrightFutures
import Foundation

enum ServiceError: Error {
    case strongSelf
    case unknown(Error?)
    case noURLForEnvironment(Environment)
    case invalidURLForEnvironment(Environment)
    case emptyResponse
    case failedToDecode
    case noInternetConnection
    case server(Error)
    case requiredPluginsNotFound([ServicePluginKey])
    case pluginError(ServicePluginError)
}

struct ServiceResult {
    var data: Data?
    var error: Error?
}

class Service {
    
    let environment: Environment
    let requester: ServiceRequester
    let pluginProvider: ServicePluginProvider
    
    let urlRequestFactory = URLRequestFactory()
    let decoder = JSONDecoder()
    
    init(environment: Environment, requester: ServiceRequester, pluginProvider: ServicePluginProvider) {
        self.environment = environment
        self.requester = requester
        self.pluginProvider = pluginProvider
    }
    
    func request<T: ServiceEndpoint>(_ endpoint: T) -> Future<T.ResponseType, ServiceError> {
        var urlRequest: URLRequest
        do {
            urlRequest = try urlRequestFactory.make(from: endpoint, in: environment)
        }
        catch let error as ServiceError {
            return Future(error: error)
        }
        catch {
            return Future(error: .unknown(error))
        }
        
        let plugins: [ServicePlugin]
        do {
            plugins = try pluginProvider.pluginsFor(endpoint)
        }
        catch let error as ServiceError {
            return Future(error: error)
        }
        catch {
            return Future(error: .unknown(error))
        }

        let promise = Promise<T.ResponseType, ServiceError>()
        
        func handleRequest() {
            Future.reduce(urlRequest, plugins) { (urlRequest, plugin) in
                return plugin.willSendRequest(urlRequest)
            }
            .mapError { (error) -> ServiceError in
                return .pluginError(error)
            }
            .onSuccess { [weak self] (urlRequest) in
                guard let requester = self?.requester else {
                    return promise.failure(.strongSelf)
                }
                
                requester.request(urlRequest) { [weak self] (result) in
                    Future.reduce(result, plugins) { (result, plugin) in
                        return plugin.didReceiveResponse(result)
                    }
                    .onFailure { (error) in
                        guard error == .retryRequest else {
                            return promise.failure(.pluginError(error))
                        }
                        handleRequest()
                    }
                    .onSuccess { [weak self] (result) in
                        guard let decoder = self?.decoder else {
                            return promise.failure(.strongSelf)
                        }

                        if let error = result.error as? URLError {
                            switch error.code.rawValue {
                            case -1009:
                                promise.failure(.noInternetConnection)
                            default:
                                promise.failure(.server(error))
                            }
                            return
                        }
                        else if let error = result.error as? ServiceError {
                            return promise.failure(error)
                        }
                        else if let error = result.error {
                            return promise.failure(.unknown(error))
                        }
                        
                        guard let data = result.data else {
                            return promise.failure(.emptyResponse)
                        }
                        guard let decodedResponse = try? decoder.decode(T.ResponseType.self, from: data) else {
                            return promise.failure(.failedToDecode)
                        }
                        
                        promise.success(decodedResponse)
                    }
                }
                
                plugins.forEach { (plugin) in
                    plugin.didSendRequest(urlRequest)
                }
            }
        }
        handleRequest()
        
        return promise.future
    }
}

func prettyPrint(_ data: Data) {
    guard let object = try? JSONSerialization.jsonObject(with: data, options: []),
          let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
          let prettyPrintedString = String(data: data, encoding: .utf8) else {
        print("Failed to pretty print Data!")
        return
    }
    
    print(prettyPrintedString)
}
