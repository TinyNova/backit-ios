/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import CoreLocation
import Foundation

enum AccountProviderError: Error {
    case none
}

protocol AccountProvider {
    func login(email: String, password: String) -> Future<User, AccountProviderError>
    func createAccount(email: String, username: String, password: String, repeatPassword: String, firstName: String, lastName: String, subscribe: Bool) -> Future<User, AccountProviderError>
}
