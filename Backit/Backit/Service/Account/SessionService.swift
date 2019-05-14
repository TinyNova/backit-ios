/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

private class AnySessionProviderListener {
    
    private(set) weak var value: AnyObject?
    
    init(_ value: AnyObject) {
        self.value = value
    }
}

class SessionService: SessionProvider {
    
    var token: String? {
        return userSession?.token
    }
    
    private var userSession: UserSession?
    private var listeners: [AnySessionProviderListener] = []
    
    /**
     Listen to changes made to the `UserSession`.
     
     This will send the current `UserSession`, if there is one.
     */
    func listen(_ listener: SessionProviderListener) {
        listeners.append(AnySessionProviderListener(listener))
        
        if let userSession = userSession {
            listener.didChangeUserSession(userSession)
        }
    }
    
    /**
     Emit a new `UserSession` to all listeners.
     */
    func emit(userSession: UserSession) {
        self.userSession = userSession
        
        listeners.forEach { (listener) in
            if let listener = listener as? SessionProviderListener {
                listener.didChangeUserSession(userSession)
            }
        }
    }
}
