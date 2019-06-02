/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

struct Credentials {
    let username: String
    let password: String
}

enum KeychainProviderError {
    case unknown(Error)
    case credentialsCorrupted
}

protocol KeychainProvider {
    func saveCredentials(_ credentials: Credentials, completion: @escaping (KeychainProviderError?) -> Void)
    func getCredentials(_ completion: @escaping (Credentials?, KeychainProviderError?) -> Void)
    func removeCredentials(_ completion: @escaping (KeychainProviderError?) -> Void)
}
