/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

typealias GuestUser = User

private enum Constant {
    static let guestId = "com.backit.backers.user.guest"
}

extension User {
    var isGuest: Bool {
        return id == Constant.guestId
    }

    init() {
        self.id = Constant.guestId
        self.avatarUrl = nil
        self.username = "Guest"
    }
}

