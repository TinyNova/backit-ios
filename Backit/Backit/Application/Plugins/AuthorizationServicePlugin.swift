/**
 * Adds the `Authorization: Bearer [token]` header to a `URLRequest`
 *
 * If the user is not logged in, then present the auth challenge. The prior request will attempt to be made after successfully logging in.
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

class AuthorizationServicePlugin: ServicePlugin {
    
    var key: ServicePluginKey = .authorization
    var token: String?
    
    func willSendRequest(_ request: URLRequest) -> URLRequest {
        // TODO: Stop the request from being made and require the user to login.
        guard let token = token else {
            return request
        }
        
        var headerFields = request.allHTTPHeaderFields ?? [String: String]()
        headerFields["Authorization"] = "Bearer: \(token)"
        var newRequest = request
        newRequest.allHTTPHeaderFields = headerFields
        return newRequest
    }
    
    func didSendRequest(_ request: URLRequest) {
    }
    
    func didReceiveResponse(_ response: ServiceResult) -> ServiceResult {
        // TODO: If the request failed because of a 403, attempt to get a new token silently. If this fails, present the login screen and try the request again.
        return response
    }

}
