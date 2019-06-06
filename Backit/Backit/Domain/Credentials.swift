/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

struct Credentials: Codable {
    let accountId: String
    let username: String
    let password: String
    let refreshToken: String
    
    func updateRefreshToken(_ newToken: String) -> Credentials {
        return Credentials(
            accountId: accountId,
            username: username,
            password: password,
            refreshToken: newToken
        )
    }
}
