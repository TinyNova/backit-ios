/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import CoreLocation
import Foundation

class AccountService: AccountProvider {
    
    private let service: Service
    private let sessionProvider: SessionProvider
    private let fileUploader: FileUploader
    
    init(service: Service, sessionProvider: SessionProvider, fileUploader: FileUploader) {
        self.service = service
        self.sessionProvider = sessionProvider
        self.fileUploader = fileUploader
    }
    
    func login(email: String, password: String) -> Future<UserSession, AccountProviderError> {
        let endpoint = LoginEndpoint(postBody: [
            .email(email),
            .password(password)
        ])
        
        return service.request(endpoint)
            .mapError { (error) -> AccountProviderError in
                return .unknown(error)
            }
            .flatMap { (response) -> Future<UserSession, AccountProviderError> in
                guard let accountId = response.accountId,
                      let csrfToken = response.csrfToken,
                      let token = response.token,
                      let refreshToken = response.refreshToken else {
                    // TODO: Map `validation` errors
                    return Future(error: .validation([:]))
                }
                return Future(value: UserSession(accountId: accountId, csrfToken: csrfToken, token: token, refreshToken: refreshToken))
            }
            .onSuccess { [weak self] (userSession) in
                self?.sessionProvider.emit(userSession: userSession)
            }
    }
    
    func logout() -> Future<NoValue, AccountProviderError> {
        return Future(error: .unknown(GenericError()))
    }
    
    func createAccount(email: String, username: String, password: String, repeatPassword: String, firstName: String, lastName: String, subscribe: Bool) -> Future<UserSession, AccountProviderError> {
        let endpoint = CreateAccountEndpoint(postBody: .init(
            email: email,
            userName: username,
            firstName: firstName,
            lastName: lastName,
            password: password,
            repeatPassword: repeatPassword,
            subscribe: subscribe
        ))
        
        return service.request(endpoint)
            .mapError { (error) -> AccountProviderError in
                return .unknown(error)
            }
            .flatMap { (response) -> Future<UserSession, AccountProviderError> in
                guard let accountId = response.accountId,
                      let csrfToken = response.csrfToken,
                      let token = response.token,
                      let refreshToken = response.refreshToken else {
                    // TODO: Map `validation` errors
                    return Future(error: .validation([:]))
                }
                return Future(value: UserSession(accountId: accountId, csrfToken: csrfToken, token: token, refreshToken: refreshToken))
            }
            .onSuccess { [weak self] (userSession) in
                self?.sessionProvider.emit(userSession: userSession)
            }
    }
        
    func silentlyReauthenticate(accountId: String, refreshToken: String) -> Future<UserSession, AccountProviderError> {
        // FIXME: This endpoint may be called more than once at a time.
        let endpoint = RefreshTokenEndpoint(postBody: [
            .accountId(accountId),
            .refreshToken(refreshToken)
        ])
        
        return service.request(endpoint)
            .mapError { (error) -> AccountProviderError in
                return .unknown(error)
            }
            .flatMap { (response) -> Future<UserSession, AccountProviderError> in
                guard let accountId = response.accountId,
                      let csrfToken = response.csrfToken,
                      let token = response.token,
                      let refreshToken = response.refreshToken else {
                    // TODO: Map `validation` errors
                    return Future(error: .validation([:]))
                }
                return Future(value: UserSession(accountId: accountId, csrfToken: csrfToken, token: token, refreshToken: refreshToken))
            }
            .onSuccess { [weak self] (userSession) in
                self?.sessionProvider.emit(userSession: userSession)
            }
    }
    
    func uploadAvatar(image: UIImage) -> Future<NoResult, AccountProviderError> {
        return Future(error: .unknown(GenericError()))
    }
}
