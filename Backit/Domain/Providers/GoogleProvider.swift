/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import BrightFutures
import UIKit

typealias GoogleAuthenticationToken = String

enum GoogleProviderError: Error {
    case generic(Error)
    case google(Error)
}

protocol GoogleProvider {
    func appDidLaunch()
    func appDidOpen(url: URL, with options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool
    func login() -> Future<GoogleAuthenticationToken, GoogleProviderError>
    func logout() -> Future<IgnorableValue, GoogleProviderError>
}
