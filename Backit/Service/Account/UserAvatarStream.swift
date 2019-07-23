/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

private class AnyUserAvatarStreamListener {
    
    private(set) weak var value: AnyObject?
    
    init(_ value: AnyObject) {
        self.value = value
    }
}

class UserAvatarStream: UserAvatarStreamer {
    
    private(set) var image: UIImage?
    
    private var listeners: [AnyUserAvatarStreamListener] = []
    
    func listen(_ listener: UserAvatarStreamListener) {
        listeners.append(AnyUserAvatarStreamListener(listener))
        
        if let image = image {
            listener.didChangeAvatar(image, state: .cached)
        }
    }
    
    func emit(image: UIImage?, state: UserAvatarStreamState) {
        self.image = image
        
        listeners.forEach { (listener) in
            if let listener = listener.value as? UserAvatarStreamListener {
                listener.didChangeAvatar(image, state: state)
            }
        }
    }
    
    // TODO: Clean `nil` listeners
}
