/**
 Provides definition of a request made to a service.
 
 License: MIT
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Alamofire
import BrightFutures
import Foundation

extension ServiceResult {
    static func make(from response: DataResponse<Data>) -> ServiceResult {
        return ServiceResult(statusCode: response.response?.statusCode, data: response.data, error: response.error)
    }
}

class AlamofireServiceRequester: ServiceRequester {
    
    let sessionManager: SessionManager
    let future: Future<IgnorableValue, NoError>
    let exclusions: [EndpointKey]

    init(sessionManager: SessionManager, start future: Future<IgnorableValue, NoError>, exclude endpoints: [EndpointKey]) {
        self.sessionManager = sessionManager
        self.future = future
        self.exclusions = endpoints
    }

    func initialized<T: ServiceEndpoint>(_ endpoint: T) -> Future<IgnorableValue, NoError> {
        if exclusions.contains(endpoint.key) {
            return Future(value: IgnorableValue())
        }
        return future
    }

    func request(_ urlRequest: URLRequest, callback: @escaping (ServiceResult) -> Void) {
        sessionManager.request(urlRequest).responseData { (response) in
            callback(ServiceResult.make(from: response))
        }
    }
}
