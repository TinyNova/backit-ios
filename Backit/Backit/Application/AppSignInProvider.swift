/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation
import UIKit

class AppSignInProvider: SignInProvider {
    
    let accountProvider: AccountProvider
    let presenterProvider: PresenterProvider
    
    var promise: Promise<UserSession, SignInProviderError>?
    var viewController: SignInViewController?
    
    init(accountProvider: AccountProvider, presenterProvider: PresenterProvider) {
        self.accountProvider = accountProvider
        self.presenterProvider = presenterProvider
    }
    
    /// Presents auth challenge to user.
    /// If called more than once, while sign in has been presented, this will return the `Future` used that initiated the login flow.
    func login() -> Future<UserSession, SignInProviderError> {
        if let promise = promise {
            return promise.future
        }
        
        let promise = Promise<UserSession, SignInProviderError>()
        self.promise = promise
        
        let storyboard = UIStoryboard(name: "SignInViewController", bundle: Bundle(for: AppSignInProvider.self))
        guard let vc = storyboard.instantiateInitialViewController() as? SignInViewController else {
            promise.failure(.unknown(GenericError()))
            return promise.future
        }
        
        viewController = vc
        vc.delegate = self
        presenterProvider.present(vc, completion: nil)
        return promise.future
    }
}

extension AppSignInProvider: SignInViewControllerDelegate {
    func didLogin(userSession: UserSession) {
        viewController?.dismiss(animated: true) { [weak self] in
            self?.promise?.success(userSession)
            self?.promise = nil
        }
    }
    
    func userCancelled() {
        viewController?.dismiss(animated: true, completion: { [weak self] in
            self?.promise?.failure(.userCanceledLogin)
            self?.promise = nil
        })
    }
}
