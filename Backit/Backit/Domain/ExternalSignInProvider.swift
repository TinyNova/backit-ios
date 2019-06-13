/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

enum ExternalSignInProviderError: Error {
    case none
}

enum ExternalSignInProviderType {
    case facebook
    case google
}

protocol ExternalSignInProvider {
    func login(with accessToken: String, provider: ExternalSignInProviderType) -> Future<UserSession, ExternalSignInProviderError>
}
