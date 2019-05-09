/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

enum SignInProviderError: Error {
    case userCanceledLogin
    case unknown(Error)
}

protocol SignInProvider {
    func login() -> Future<UserSession, SignInProviderError>
}
