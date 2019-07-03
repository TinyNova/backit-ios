/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

struct UserSession: Codable {
    let accountId: String
    let csrfToken: String
    let token: String
    let refreshToken: String
}
