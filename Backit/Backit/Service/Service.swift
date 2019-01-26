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
    
    let decoder = JSONDecoder()
    
    init(environment: Environment) {
        self.environment = environment
    }
    
    func request<T: ServiceRequest>(_ request: T) -> Future<T.ResponseType, ServiceError> {
        let urlRequest: URLRequest
        do {
            urlRequest = try urlRequestFor(request: request, in: environment)
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
    
    // MARK: - Private Methods
    
    private func urlRequestFor<T: ServiceRequest>(request: T, in environment: Environment) throws -> URLRequest {
        guard let urlString = request.endpoints[environment] else {
            throw ServiceError.noURLForEnvironment(environment)
        }
        
        var urlComponents = URLComponents(string: urlString)
        urlComponents?.queryItems = queryItems(for: request)
        
        guard let url = urlComponents?.url else {
            throw ServiceError.invalidURLForEnvironment(environment)
        }
        
        return URLRequest(url: url)
    }
    
    private func queryItems<T: ServiceRequest>(for request: T) -> [URLQueryItem] {
        guard let params = request.queryParameters else {
            return []
        }
        
        return params.compactMap { (parameter) -> URLQueryItem? in
            let string = "\(parameter)"
            guard let range = string.range(of: "(") else {
                print("Failed to extract key/value GET parameter for \(parameter). It must be an `enum` case with a single associated value.")
                return nil
            }
            
            let name = string.prefix(upTo: range.lowerBound)
            
            let startIndex = string.index(after: range.lowerBound)
            let endIndex = string.index(before: string.endIndex)
            let valueSubstring = string[startIndex..<endIndex]
            let value = String(valueSubstring).replacingOccurrences(of: "\"", with: "")
            
            return URLQueryItem(name: String(name), value: value)
        }
    }
}
