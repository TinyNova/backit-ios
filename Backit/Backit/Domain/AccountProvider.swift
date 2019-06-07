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
    case service(String)
    case validation([AccountValidationField: [AccountValidationMessage]])
    case failedToDecode(type: String)
}

protocol AccountProvider {
    func login(email: String, password: String) -> Future<UserSession, AccountProviderError>
    func logout() -> Future<IgnorableValue, AccountProviderError>
    func createAccount(email: String, username: String, password: String, repeatPassword: String, firstName: String?, lastName: String?, subscribe: Bool) -> Future<UserSession, AccountProviderError>
    func silentlyReauthenticate(accountId: String, refreshToken: String) -> Future<UserSession, AccountProviderError>
    func uploadAvatar(image: UIImage) -> Future<IgnorableValue, AccountProviderError>
}
