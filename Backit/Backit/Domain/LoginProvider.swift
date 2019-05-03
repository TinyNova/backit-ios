/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

enum LoginProviderError: Error {
    case none
}

protocol LoginProvider {
    func displayLogin() -> Future<UserSession, LoginProviderError>
}
