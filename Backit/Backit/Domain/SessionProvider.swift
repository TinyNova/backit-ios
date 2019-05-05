/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

typealias SessionProviderCallback = (UserSession) -> Void

enum SessionProviderError: Error {
    case unknown(Error)
}

/// TODO: Rename to `UserSessionStream`
/// TODO: Create another protocol `UserStream`
protocol SessionProvider {
    func listen(_ callback: @escaping SessionProviderCallback)
    func silentlyReauthenticate() -> Future<UserSession, SessionProviderError>
}
