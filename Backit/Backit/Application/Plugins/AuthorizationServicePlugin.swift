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
    
    private var userSession: UserSession?
    
    private let signInProvider: SignInProvider
    private let sessionStream: UserSessionStreamer
    private let accountProvider: AccountProvider
    
    init(signInProvider: SignInProvider, sessionStream: UserSessionStreamer, accountProvider: AccountProvider) {
        self.signInProvider = signInProvider
        self.sessionStream = sessionStream
        self.accountProvider = accountProvider
    }
    
    func willSendRequest(_ request: URLRequest) -> Future<URLRequest, ServicePluginError> {
        let promise = Promise<URLRequest, ServicePluginError>()

        // Login, if the user has not yet logged in.
        guard let token = sessionStream.token else {
            signInProvider.login()
                .onSuccess { [weak self] (userSession) in
                    self?.userSession = userSession
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
        // This is NOT a refresh token issue
        guard let statusCode = response.statusCode, statusCode == 401 else {
            return Future(value: response)
        }
        
        let promise = Promise<ServiceResult, ServicePluginError>()
        
        // The session expired but we don't have a session!
        // Attempt to log the user in
        guard let accountId = userSession?.accountId, let refreshToken = userSession?.refreshToken else {
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
        
        // The user's session has expired. Attempt to silently re-auth.
        accountProvider.silentlyReauthenticate(accountId: accountId, refreshToken: refreshToken)
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
                
                // Attempt to log the user in
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
    
    private func updateRequest(_ request: URLRequest, with token: String, on promise: Promise<URLRequest, ServicePluginError>) {
        var headerFields = request.allHTTPHeaderFields ?? [String: String]()
        headerFields["Authorization"] = "Bearer \(token)"
        var newRequest = request
        newRequest.allHTTPHeaderFields = headerFields
        promise.success(newRequest)
    }
}

extension AuthorizationServicePlugin: SessionProviderListener {
    func didChangeUserSession(_ userSession: UserSession?) {
        self.userSession = userSession
    }
}
