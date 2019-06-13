/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

typealias FacebookAccessToken = String

enum FacebookProviderError: Error {
    case facebook(Error)
    case failedToPresent
    case failedToLogin
    case failedToDecodeProfile
}

protocol FacebookProvider {
    func login() -> Future<
        FacebookAccessToken, FacebookProviderError>
}
