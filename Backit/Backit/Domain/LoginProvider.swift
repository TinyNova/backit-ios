/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

enum LoginProviderError: Error {
    case userCanceledLogin
}

protocol LoginProvider {
    func login() -> Future<UserSession, LoginProviderError>
}
