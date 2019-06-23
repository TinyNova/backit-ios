/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

enum PhotoAlbumProviderError: Error {
    // User selected a media type (Image) that we do not support
    case didNotSelectValidMedia
    
    // User cancelled the action
    case userCancelled
    
    // App does not have permissions to access the user's photo album
    case noPermission
}

protocol PhotoAlbumProvider {
    func requestImage(callback: @escaping (UIImage?, PhotoAlbumProviderError?) -> Void)
}
