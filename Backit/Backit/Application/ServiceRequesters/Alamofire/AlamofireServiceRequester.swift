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
    let exclusions: [String]
    
    init(sessionManager: SessionManager, start future: Future<IgnorableValue, NoError>, exclude endpoints: [String]) {
        self.sessionManager = sessionManager
        self.future = future
        self.exclusions = endpoints
    }
    
    func request(_ urlRequest: URLRequest, callback: @escaping (ServiceResult) -> Void) {
        if let url = urlRequest.url, exclusions.contains(url.absoluteString) {
            sessionManager.request(urlRequest).responseData { (response) in
                callback(ServiceResult.make(from: response))
            }
            return
        }

        future.onSuccess { [weak self] _ in
            guard let sself = self else {
                log.c("Failed to get strong self for AlamofireServiceRequester - no calls can be made")
                return
            }
            sself.sessionManager.request(urlRequest).responseData { (response) in
                callback(ServiceResult.make(from: response))
            }
        }
    }
}
