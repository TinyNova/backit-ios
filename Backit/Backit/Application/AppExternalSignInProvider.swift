/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

class AppExternalSignInProvider: ExternalSignInProvider {
    
    let accountProvider: AccountProvider
    
    init(accountProvider: AccountProvider) {
        self.accountProvider = accountProvider
    }
    
    func login(with accessToken: String, provider: ExternalSignInProviderType) -> Future<UserSession, ExternalSignInProviderError> {
        return Future(error: .none)
    }
}
