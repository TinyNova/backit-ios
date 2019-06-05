/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

protocol UserStreamListener: AnyObject {
    func didChangeUser(_ user: User?)
}

protocol UserStreamer {
    func listen(_ listener: UserStreamListener)
    func emit(user: User?)
}
