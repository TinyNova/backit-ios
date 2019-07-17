/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

private class AnyUserStreamListener {
    
    private(set) weak var value: AnyObject?
    
    init(_ value: AnyObject) {
        self.value = value
    }
}

class UserStream: UserStreamer {
    
    private(set) var user: User?
    
    private var listeners: [AnyUserStreamListener] = []

    func listen(_ listener: UserStreamListener) {
        listeners.append(AnyUserStreamListener(listener))

        if let user = user {
            listener.didChangeUser(user)
        }
    }
    
    func emit(user: User) {
        self.user = user
        
        listeners.forEach { (listener) in
            if let listener = listener.value as? UserStreamListener {
                listener.didChangeUser(user)
            }
        }
    }
    
    // TODO: Clean `nil` listeners
}
