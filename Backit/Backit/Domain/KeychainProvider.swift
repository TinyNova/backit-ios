/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

enum KeychainProviderError {
    case unknown(Error)
    case credentialsCorrupted
    case failedToEncodeCredentials
    case failedToDecodeCredentials
}

protocol KeychainProvider {
    func saveCredentials(_ credentials: Credentials, completion: @escaping (KeychainProviderError?) -> Void)
    func getCredentials(_ completion: @escaping (Credentials?, KeychainProviderError?) -> Void)
    func removeCredentials(_ completion: @escaping (KeychainProviderError?) -> Void)
}
