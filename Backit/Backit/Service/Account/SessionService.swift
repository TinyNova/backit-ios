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
//    private var listeners: [UserSessionListener] = []
    
    func listen(_ listener: UserSessionListener) {
        // TODO: Not implemented
    }
    
    func emit(userSession: UserSession) {
        self.userSession = userSession
        // TODO: Not implemented
    }
}
