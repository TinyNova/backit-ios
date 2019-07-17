/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

typealias UserId = String

struct User: Equatable {
    let id: UserId
    let avatarUrl: URL?
    let username: String
}
