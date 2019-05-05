/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

class AppLoginProvider: LoginProvider {
    
    let accountProvider: AccountProvider
    
    init(accountProvider: AccountProvider) {
        self.accountProvider = accountProvider
    }
    
    func login() -> Future<UserSession, LoginProviderError> {
        // TODO: Display screen which gets username/password
        // TODO: Login with credentials
        // TODO: This screen only goes away when the user cancels or logging in is successful
        return accountProvider.login(email: "eric.chamberlain@backit.com", password: "Password1!")
            .mapError { (error) -> LoginProviderError in
                return .userCanceledLogin
            }
    }
}
