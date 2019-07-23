/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

private enum Constant {
    static let guestId = "com.backit.backers.user.guest"
}

extension User {
    var isGuest: Bool {
        return id == Constant.guestId
    }

    static func guest() -> User {
        return User(id: Constant.guestId, avatarUrl: nil, username: "Guest")
    }
}

