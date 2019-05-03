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
    
    func login(email: String, password: String) -> Future<User, AccountProviderError> {
        let endpoint = LoginEndpoint(postParameters: [
            .email(email),
            .password(password)
        ])
        
        return service.request(endpoint)
            .mapError { (error) -> AccountProviderError in
                return .none
            }
            .flatMap { [weak self] (response) -> Future<User, AccountProviderError> in
                guard let sself = self else { return Future(error: .none) }
                return sself.user()
            }
    }
    
    func createAccount(email: String, username: String, password: String, repeatPassword: String, firstName: String, lastName: String, subscribe: Bool) -> Future<User, AccountProviderError> {
        let endpoint = CreateAccountEndpoint(postParameters: [
            .email(email),
            .userName(username),
            .password(password),
            .repeatPassword(repeatPassword),
            .subscribe(subscribe)
        ])
        
        return service.request(endpoint)
            .mapError { (error) -> AccountProviderError in
                return .none
            }
            .flatMap { [weak self] (response) -> Future<User, AccountProviderError> in
                guard let sself = self else { return Future(error: .none) }
                return sself.user()
            }
    }
    
    func user() -> Future<User, AccountProviderError> {
        let endpoint = UserAccountEndpoint()
        
        return service.request(endpoint)
            .map { response -> User in
                return User(avatarUrl: URL(string: "http:www.example.com")!, username: "PeqNP")
            }
            .mapError { error -> AccountProviderError in
                return .none
            }
    }
}
