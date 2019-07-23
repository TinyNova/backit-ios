/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

enum KeychainProviderError: Error {
    case unknown(Error)
    case credentialsCorrupted
    case credentialsNotProvided
    case failedToEncode
    case failedToDecode
    case noStoredCredentials
}

protocol KeychainProvider {
    func saveUserSession(_ userSession: UserSession) -> Future<IgnorableValue, KeychainProviderError>
    func userSession() -> Future<UserSession, KeychainProviderError>

    func saveCredentials(_ credentials: Credentials?) -> Future<IgnorableValue, KeychainProviderError>
    func credentials() -> Future<Credentials, KeychainProviderError>

    func removeAll() -> Future<IgnorableValue, KeychainProviderError>
}
