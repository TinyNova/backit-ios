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
    case generic(Error)
    case validation([AccountValidationField: [AccountValidationMessage]])
    case failedToDecode(type: String)
    case thirdParty(Error)
}

enum ExternalUserProvider {
    case facebook
    case google
}

struct ExternalUserProfile {
    let type: ExternalUserProvider?
    let id: String?
    let firstName: String?
    let lastName: String?
    let email: String?
    let avatarUrl: URL?
}

typealias UsernameAvailable = Bool

enum ExternalAccount {
    case existingUser(UserSession)
    case newUser(signupToken: String, profile: ExternalUserProfile)
}

struct AccountServiceHealth {
    let environment: String
    let services: [String: Bool]
}

protocol AccountProvider {
    func health() -> Future<AccountServiceHealth, AccountProviderError>
    
    func login(email: String, password: String) -> Future<UserSession, AccountProviderError>
    func logout() -> Future<IgnorableValue, AccountProviderError>
    
    func externalLogin(accessToken: String, provider: String)  -> Future<ExternalAccount, AccountProviderError>
    func createExternalAccount(email: String, username: String, subscribe: Bool, signupToken: String) -> Future<UserSession, AccountProviderError>
    func usernameAvailable(username: String) -> Future<UsernameAvailable, AccountProviderError>
    
    func createAccount(email: String, username: String, password: String, repeatPassword: String, firstName: String?, lastName: String?, subscribe: Bool) -> Future<UserSession, AccountProviderError>
    func resetPassword(email: String) -> Future<IgnorableValue, AccountProviderError>
    func silentlyReauthenticate(accountId: String, refreshToken: String) -> Future<UserSession, AccountProviderError>
    func uploadAvatar(image: UIImage) -> Future<IgnorableValue, AccountProviderError>
}
