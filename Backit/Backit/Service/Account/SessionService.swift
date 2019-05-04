/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

class SessionService: SessionProvider {
    func listen(_ callback: @escaping SessionProviderCallback) {
        
    }
    
    func silentlyReauthenticate() -> Future<UserSession, SessionProviderError> {
        return Future(error: .unknown(GenericError()))
    }
}
