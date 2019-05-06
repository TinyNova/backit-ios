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
    
    private var token: String?
    
    private let loginProvider: LoginProvider
    private let sessionProvider: SessionProvider
    private let accountProvider: AccountProvider
    
    init(loginProvider: LoginProvider, sessionProvider: SessionProvider, accountProvider: AccountProvider) {
        self.loginProvider = loginProvider
        self.sessionProvider = sessionProvider
        self.accountProvider = accountProvider
    }
    
    func willSendRequest(_ request: URLRequest) -> Future<URLRequest, ServicePluginError> {
        let promise = Promise<URLRequest, ServicePluginError>()

        // Login, if the user has not yet logged in.
        guard let token = sessionProvider.token else {
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
        // NOTE: The response is a 401 with a `SUCCESS` and a `message` that says "Invalid token"
        guard let error = response.error as? URLError else {
            return Future(value: response)
        }
        guard error.code.rawValue == 403 else {
            return Future(value: response)
        }
        
        let promise = Promise<ServiceResult, ServicePluginError>()
        
        // The user failed to login because the session expired. Attempt to silently re-auth.
        accountProvider.silentlyReauthenticate()
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

extension AuthorizationServicePlugin: UserSessionListener {
    func didChangeUserSession(_ userSession: UserSession) {
        token = userSession.token
    }
}
