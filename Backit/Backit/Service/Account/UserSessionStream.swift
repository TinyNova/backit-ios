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

class UserSessionStream: UserSessionStreamer {
    
    var token: String? {
        return userSession?.token
    }
    
    private let userProvider: UserProvider
    private let userStreamer: UserStreamer
    
    private var userSession: UserSession?
    private var listeners: [AnySessionProviderListener] = []
    
    init(userProvider: UserProvider, userStreamer: UserStreamer) {
        self.userProvider = userProvider
        self.userStreamer = userStreamer
    }
    
    func listen(_ listener: UserSessionListener) {
        listeners.append(AnySessionProviderListener(listener))
        
        if let userSession = userSession {
            listener.didChangeUserSession(userSession)
        }
    }
    
    func emit(userSession: UserSession?) {
        self.userSession = userSession
        
        listeners.forEach { (listener) in
            if let listener = listener.value as? UserSessionListener {
                listener.didChangeUserSession(userSession)
            }
        }
        
        guard userSession != nil else {
            userStreamer.emit(user: nil)
            return
        }
        
        userProvider.user().onSuccess { [weak self] (user) in
            self?.userStreamer.emit(user: user)
        }
    }
    
    // TODO: Clean `nil` listeners
}
