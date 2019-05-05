/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import CoreLocation
import Foundation

class AccountService: AccountProvider {
    
    let service: Service
    
    init(service: Service) {
        self.service = service
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
            // NOTE: This is for future reference
//          .flatMap { [weak self] (response) -> Future<User, AccountProviderError> in
//              guard let sself = self else { return Future(error: .none) }
//              return sself.user()
//          }
    }
    
    func user() -> Future<User, AccountProviderError> {
        let endpoint = UserAccountEndpoint()
        
        // TODO: Find a way to easily get at the response data without having to go into the service.
        // TODO: Map the server response to `User` model.
        return service.request(endpoint)
            .map { response -> User in
                return User(avatarUrl: URL(string: "http:www.example.com")!, username: "PeqNP")
            }
            .mapError { error -> AccountProviderError in
                return .unknown(error)
            }
    }
}
