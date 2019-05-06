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
    
    init(service: Service, sessionProvider: SessionProvider) {
        self.service = service
        self.sessionProvider = sessionProvider
    }
    
    func login(email: String, password: String) -> Future<UserSession, AccountProviderError> {
        let endpoint = LoginEndpoint(postParameters: [
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
                      let token = response.token else {
                    // TODO: Map `validation` errors
                    return Future(error: .validation([:]))
                }
                return Future(value: UserSession(accountId: accountId, csrfToken: csrfToken, token: token))
            }
            .onSuccess { [weak self] (userSession) in
                self?.sessionProvider.emit(userSession: userSession)
            }
    }
    
    func createAccount(email: String, username: String, password: String, repeatPassword: String, firstName: String, lastName: String, subscribe: Bool) -> Future<UserSession, AccountProviderError> {
        let endpoint = CreateAccountEndpoint(postParameters: [
            .email(email),
            .userName(username),
            .password(password),
            .repeatPassword(repeatPassword),
            .subscribe(subscribe)
        ])
        
        return service.request(endpoint)
            .mapError { (error) -> AccountProviderError in
                return .unknown(error)
            }
            .flatMap { (response) -> Future<UserSession, AccountProviderError> in
                guard let accountId = response.accountId,
                      let csrfToken = response.csrfToken,
                      let token = response.token else {
                    // TODO: Map `validation` errors
                    return Future(error: .validation([:]))
                }
                return Future(value: UserSession(accountId: accountId, csrfToken: csrfToken, token: token))
            }
            .onSuccess { [weak self] (userSession) in
                self?.sessionProvider.emit(userSession: userSession)
            }
    }
    
    func user() -> Future<User, AccountProviderError> {
        let endpoint = UserAccountEndpoint()
        
        // TODO: Find a way to easily get at the response data without having to go into the service.
        // TODO: Map the server response to `User` model.
        return service.request(endpoint)
            .mapError { error -> AccountProviderError in
                return .unknown(error)
            }
            .flatMap { (response) -> Future<User, AccountProviderError> in
                guard response.message == nil else {
                    return Future(error: .notLoggedIn)
                }
                return Future(value: User(avatarUrl: response.avatar, username: response.userName))
            }
    }
    
    func silentlyReauthenticate() -> Future<UserSession, AccountProviderError> {
        // TODO: Emit signal on SessionProvider
        return Future(error: .unknown(NotImplementedError()))
    }
}
