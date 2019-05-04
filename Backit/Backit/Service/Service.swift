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
        Future.reduce(urlRequest, plugins) { (urlRequest, plugin) in
            return plugin.willSendRequest(urlRequest)
        }
        .mapError { (error) -> ServiceError in
            // TODO: Depending on the `PluginError` provided by the `Plugin` do something.
            return .unknown(error)
        }
        .onSuccess { [weak self] (urlRequest) in
            guard let requester = self?.requester else {
                return promise.failure(.strongSelf)
            }
            
            requester.request(urlRequest) { [weak self] (result) in
                guard let decoder = self?.decoder else {
                    return promise.failure(.strongSelf)
                }
                
                Future.reduce(result, plugins) { (result, plugin) in
                    return plugin.didReceiveResponse(result)
                }
                .onFailure { (error) in
                    if error == .retryRequest {
                        // TODO: Create inline functions to capture `ServiceEndpoint` and other state (possibly including retry count) and clean this up to reduce levels.
                        self?.request(endpoint)
                        return
                    }
                }

//                let result = plugins.reduce(result) { (response, plugin) -> ServiceResult in
//                    return plugin.didReceiveResponse(response)
//                }
                
                // TODO: Allow `Plugin` to manage errors OR provide capability to retry login if 403.
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
                    promise.failure(error)
                    return
                }
                else if let error = result.error {
                    promise.failure(.unknown(error))
                    return
                }
                
                guard let data = result.data else {
                    promise.failure(.emptyResponse)
                    return
                }
                guard let decodedResponse = try? decoder.decode(T.ResponseType.self, from: data) else {
                    promise.failure(.failedToDecode)
                    return
                }
                
                promise.success(decodedResponse)
            }
            
            plugins.forEach { (plugin) in
                plugin.didSendRequest(urlRequest)
            }
        }
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
