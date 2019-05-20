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

protocol SessionProviderListener: AnyObject {
    func didChangeUserSession(_ userSession: UserSession)
}

/// TODO: Rename to `UserSessionStreamer`
protocol SessionProvider {
    var token: String? { get }
    
    /**
     Listen to changes made to the `UserSession`.
     
     This will send the current `UserSession`, if there is one.
     */
    func listen(_ listener: SessionProviderListener)
    
    /**
     Emit a new `UserSession` to all listeners.
     */
    func emit(userSession: UserSession)
}
