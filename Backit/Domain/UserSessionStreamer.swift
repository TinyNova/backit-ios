/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

protocol UserSessionListener: AnyObject {
    func didChangeUserSession(_ userSession: UserSession?)
}

protocol UserSessionStreamer {
    var token: String? { get }
    
    /**
     Listen to changes made to the `UserSession`.
     
     This will send the current `UserSession`, if there is one.
     */
    func listen(_ listener: UserSessionListener)
    
    /**
     Emit a new `UserSession` to all listeners.
     */
    func emit(userSession: UserSession?)
}
