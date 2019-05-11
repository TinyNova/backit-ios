/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

class SessionService: SessionProvider {
    
    var token: String? {
        return userSession?.token
    }
    
    private var userSession: UserSession?
    // This must be `weak`
    private var listeners: [SessionProviderListener] = []
    
    func listen(_ listener: SessionProviderListener) {
        // TODO: Not implemented
    }
    
    func emit(userSession: UserSession) {
        self.userSession = userSession
        // TODO: Not implemented
    }
}
