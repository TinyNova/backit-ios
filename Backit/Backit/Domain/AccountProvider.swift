/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import CoreLocation
import Foundation

enum AccountValidationField {
    case email
    case firstName
    case lastName
    case username
    case password
}

typealias AccountValidationMessage = String

enum AccountProviderError: Error {
    case unknown(Error)
    case validation([AccountValidationField: [AccountValidationMessage]])
}

protocol AccountProvider {
    func login(email: String, password: String) -> Future<UserSession, AccountProviderError>
    func createAccount(email: String, username: String, password: String, repeatPassword: String, firstName: String, lastName: String, subscribe: Bool) -> Future<UserSession, AccountProviderError>
    func user() -> Future<User, AccountProviderError>
}
