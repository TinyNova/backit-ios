/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

class AppLoginProvider: LoginProvider {
    func login() -> Future<UserSession, LoginProviderError> {
        return Future(value: UserSession(accountId: "account-id", csrfToken: "csrf-token", token: "token"))
    }
}
