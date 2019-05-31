/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

enum UserProviderError: Error {
    case unknown(Error)
    case notLoggedIn
}

protocol UserProvider {
    func user() -> Future<User, UserProviderError>
}
