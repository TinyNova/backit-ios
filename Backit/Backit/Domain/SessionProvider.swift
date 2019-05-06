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

protocol UserSessionListener: class {
    func didChangeUserSession(_ userSession: UserSession)
}

/// TODO: Rename to `UserSessionStream`
/// TODO: Create another protocol `UserStream`
protocol SessionProvider {
    var token: String? { get }
    
    func listen(_ listener: UserSessionListener)
    func emit(userSession: UserSession)
}
