/**
 * Adds the `Authorization: Bearer [token]` header to a `URLRequest`
 *
 * User Login Flow
 *
 * Attempt to auth via modal:
 * - If success, continue request
 * - If cancel, display error saying they must login to see feature
 *
 * If possible, attempt to silent reauthorize:
 * - If success, continue request
 * - If failed, display login modal
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

import BrightFutures

struct GenericError: Error {
    
}

struct Session {
    let accountId: String
    let csrfToken: String
    let token: String
}

enum LoginProviderError: Error {
    case none
}

protocol LoginProvider {
    func displayLogin() -> Future<Session, LoginProviderError>
}

class AuthorizationServicePlugin: ServicePlugin {
    
    var key: ServicePluginKey = .authorization
    var token: String?
    
    let loginProvider: LoginProvider
    
    init(loginProvider: LoginProvider) {
        self.loginProvider = loginProvider
    }
    
    func willSendRequest(_ request: URLRequest) -> Future<URLRequest, ServicePluginError> {
        // TODO: Stop the request from being made and require the user to login.
        // Return Future
        guard let token = token else {
            return Future(error: .none)
        }
        
        var headerFields = request.allHTTPHeaderFields ?? [String: String]()
        headerFields["Authorization"] = "Bearer: \(token)"
        var newRequest = request
        newRequest.allHTTPHeaderFields = headerFields
        return Future(value: newRequest)
    }
    
    func didSendRequest(_ request: URLRequest) {
    }
    
    func didReceiveResponse(_ response: ServiceResult) -> ServiceResult {
        // TODO: If the request failed because of a 403, attempt to get a new token silently. If this fails, present the login screen and try the request again.
        return response
    }

}
