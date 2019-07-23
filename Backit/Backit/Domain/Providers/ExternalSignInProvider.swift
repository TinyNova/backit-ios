/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation
import UIKit

enum ExternalSignInProviderError: Error {
    case failedToSignIn
    case failedToFinishAccountCreation
    case generic(Error)
}

enum ExternalSignInProviderType {
    case facebook
    case google
}

protocol ExternalSignInProviderDelegate: class {
    func present(_ viewController: UIViewController)
}

protocol ExternalSignInProvider {
    var delegate: ExternalSignInProviderDelegate? { get set }
    
    func login(with accessToken: String, provider: ExternalSignInProviderType) -> Future<UserSession, ExternalSignInProviderError>
}
