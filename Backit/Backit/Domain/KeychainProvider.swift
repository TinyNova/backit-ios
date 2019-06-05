/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

enum KeychainProviderError: Error {
    case unknown(Error)
    case credentialsCorrupted
    case failedToEncodeCredentials
    case failedToDecodeCredentials
}

protocol KeychainProvider {
    func saveCredentials(_ credentials: Credentials) -> Future<IgnorableValue, KeychainProviderError>
    func getCredentials() -> Future<Credentials, KeychainProviderError>
    func removeCredentials() -> Future<IgnorableValue, KeychainProviderError>
}
