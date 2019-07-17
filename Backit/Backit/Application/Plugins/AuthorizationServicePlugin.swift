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
 * NOTE: The reason the error .strongSelf is consistently returned is to prevent a possible loop.
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import BrightFutures

class AuthorizationServicePlugin: ServicePlugin {
    
    var key: ServicePluginKey = .authorization
    
    private var userSession: UserSession?
    
    private let signInProvider: SignInProvider
    private let accountProvider: AccountProvider
    
    init(signInProvider: SignInProvider, sessionStream: UserSessionStreamer, accountProvider: AccountProvider) {
        self.signInProvider = signInProvider
        self.accountProvider = accountProvider
        sessionStream.listen(self)
    }
    
    func willSendRequest(_ request: URLRequest) -> Future<URLRequest, ServicePluginError> {
        let promise = Promise<URLRequest, ServicePluginError>()

        // Login if the user has not yet logged in.
        guard let userSession = userSession else {
            signInProvider.login()
                .onSuccess { [weak self] (userSession) in
                    guard let sself = self else {
                        return promise.failure(.strongSelf)
                    }

                    sself.userSession = userSession
                    sself.updateRequest(request, with: userSession, on: promise)
                }
                .onFailure { (error) in
                    promise.failure(.failedToLogin)
                }
            return promise.future
        }
        
        updateRequest(request, with: userSession, on: promise)
        return promise.future
    }
    
    func didSendRequest(_ request: URLRequest) {
    }
    
    func didReceiveResponse(_ response: ServiceResult, history: RequestHistory) -> Future<ServiceResult, ServicePluginError> {
        guard history.responses.last?.statusCode != 401 else {
            return Future(error: .requestFailed)
        }
        // This is NOT a refresh token issue
        guard let statusCode = response.statusCode, statusCode == 401 else {
            return Future(value: response)
        }
        
        let promise = Promise<ServiceResult, ServicePluginError>()
        
        // There is no session. Attempt to log the user in.
        guard let userSession = userSession else {
            signInProvider.login()
                .onSuccess { [weak self] (userSession) in
                    guard let sself = self else {
                        return promise.failure(.strongSelf)
                    }
                    
                    sself.userSession = userSession
                    promise.failure(.retryRequest)
                }
                .onFailure { (error) in
                    promise.failure(.failedToLogin)
                }
            return promise.future
        }
        
        // The session has expired. Attempt to silently re-auth.
        accountProvider.silentlyReauthenticate(accountId: userSession.accountId, refreshToken: userSession.refreshToken)
            .onSuccess { [weak self] (userSession) in
                guard let sself = self else {
                    return promise.failure(.strongSelf)
                }
                
                sself.userSession = userSession
                promise.failure(.retryRequest)
            }
            .onFailure { [weak self] (error) in
                guard let sself = self else {
                    return promise.failure(.strongSelf)
                }
                
                // Lastly, attempt to log the user in
                sself.signInProvider.login()
                    .onSuccess { [weak self] (userSession) in
                        guard let sself = self else {
                            return promise.failure(.strongSelf)
                        }
                        
                        sself.userSession = userSession
                        promise.failure(.retryRequest)
                    }
                    .onFailure { (error) in
                        promise.failure(.failedToLogin)
                    }
            }
        
        return promise.future
    }

    // MARK: - Private Methods
    
    private func updateRequest(_ request: URLRequest, with userSession: UserSession, on promise: Promise<URLRequest, ServicePluginError>) {
        var headerFields = request.allHTTPHeaderFields ?? [String: String]()
        headerFields["Authorization"] = "Bearer \(userSession.token)"
        headerFields["X-Csrf-Token"] = userSession.csrfToken
        var newRequest = request
        newRequest.allHTTPHeaderFields = headerFields
        promise.success(newRequest)
    }
}

extension AuthorizationServicePlugin: UserSessionListener {
    func didChangeUserSession(_ userSession: UserSession?) {
        self.userSession = userSession
    }
}
