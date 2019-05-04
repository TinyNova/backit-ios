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

class AuthorizationServicePlugin: ServicePlugin {
    
    var key: ServicePluginKey = .authorization
    var token: String?
    
    let loginProvider: LoginProvider
    let sessionProvider: SessionProvider
    
    init(loginProvider: LoginProvider, sessionProvider: SessionProvider) {
        self.loginProvider = loginProvider
        self.sessionProvider = sessionProvider
        
        sessionProvider.listen { [weak self] (userSession) in
            self?.token = userSession.token
        }
    }
    
    func willSendRequest(_ request: URLRequest) -> Future<URLRequest, ServicePluginError> {
        let promise = Promise<URLRequest, ServicePluginError>()

        // Login, if the user has not yet logged in.
        guard let token = token else {
            loginProvider.login()
                .onSuccess { [weak self] (userSession) in
                    self?.token = userSession.token
                    self?.updateRequest(request, with: userSession.token, on: promise)
                }
                .onFailure { (error) in
                    promise.failure(.failedToLogin)
                }
            return promise.future
        }
        
        updateRequest(request, with: token, on: promise)
        return promise.future
    }
    
    func didSendRequest(_ request: URLRequest) {
    }
    
    func didReceiveResponse(_ response: ServiceResult) -> Future<ServiceResult, ServicePluginError> {
        guard let error = response.error as? URLError else {
            return Future(value: response)
        }
        guard error.code.rawValue == 403 else {
            return Future(value: response)
        }
        
        let promise = Promise<ServiceResult, ServicePluginError>()
        
        // The user failed to login because the session expired. Attempt to silently re-auth.
        sessionProvider.silentlyReauthenticate()
            .onSuccess { [weak self] (userSession) in
                guard let sself = self else {
                    return promise.failure(.strongSelf)
                }
                
                sself.token = userSession.token
                promise.failure(.retryRequest)
            }
            .onFailure { [weak self] (error) in
                guard let sself = self else {
                    return promise.failure(.strongSelf)
                }
                
                // Attempt to log the user in
                sself.loginProvider.login()
                    .onSuccess { [weak self] (userSession) in
                        guard let sself = self else {
                            return promise.failure(.strongSelf)
                        }
                        
                        sself.token = userSession.token
                        promise.failure(.retryRequest)
                    }
                    .onFailure { (error) in
                        promise.failure(.failedToLogin)
                    }
            }
        
        return promise.future
    }

    // MARK: - Private Methods
    
    private func updateRequest(_ request: URLRequest, with token: String, on promise: Promise<URLRequest, ServicePluginError>) {
        var headerFields = request.allHTTPHeaderFields ?? [String: String]()
        headerFields["Authorization"] = "Bearer: \(token)"
        var newRequest = request
        newRequest.allHTTPHeaderFields = headerFields
        promise.success(newRequest)
    }
}
