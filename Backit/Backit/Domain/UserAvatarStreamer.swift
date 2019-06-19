/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

enum UserAvatarStreamState {
    case uploading
    case uploaded
    case failed
    case cached
}

protocol UserAvatarStreamListener: AnyObject {
    func didChangeAvatar(_ image: UIImage?, state: UserAvatarStreamState)
}

protocol UserAvatarStreamer {
    func listen(_ listener: UserAvatarStreamListener)
    func emit(image: UIImage?, state: UserAvatarStreamState)
}
