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
    
    func login(username: String, password: String) -> Future<User, AccountProviderError> {
        return Future(error: .none)
    }
    
    func createAccount(email: String, username: String, password: String, repeatPassword: String, firstName: String, lastName: String, location: CLLocation, subscribe: Bool) -> Future<User, AccountProviderError> {
        return Future(error: .none)
    }
}
