/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

struct Credentials {
    let username: String
    let password: String
}

protocol KeychainProvider {
    func saveCredentials(_ credentials: Credentials, completion: () -> Void)
    func getCredentials(_ completion: (Credentials?) -> Void)
    func removeCredentials(_ completion: () -> Void)
}
