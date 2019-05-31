/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation
import UIKit

class AppSignInProvider: SignInProvider {
    
    let keychainProvider: KeychainProvider
    let accountProvider: AccountProvider
    let presenterProvider: PresenterProvider
    
    var promise: Promise<UserSession, SignInProviderError>?
    var viewController: SignInViewController?
    
    init(keychainProvider: KeychainProvider, accountProvider: AccountProvider, presenterProvider: PresenterProvider) {
        self.keychainProvider = keychainProvider
        self.accountProvider = accountProvider
        self.presenterProvider = presenterProvider
    }
    
    /**
     * Presents auth challenge to user.
     *
     * If called more than once, while sign in has been presented, this will return the same `Future` used when intially starting the login flow.
     */
    func login() -> Future<UserSession, SignInProviderError> {
        if let promise = promise {
            return promise.future
        }
        
        let promise = Promise<UserSession, SignInProviderError>()
        self.promise = promise
        
        keychainProvider.getCredentials { [weak self] (credentials) in
            guard let credentials = credentials else {
                // Challenge user with login
                self?.loginUsingForm(promise: promise)
                return
            }
            
            // Login using credentials from keychain
            self?.loginUsingCredentials(credentials, promise: promise)
        }
        
        return promise.future
    }
    
    /**
     * Attempt to login the user with the stored credentials.
     *
     * If the process fails because of a networking issue, then the user will be asked to login.
     * If the process fails because of validation, then credentials will be removed and the user will be asked to login.
     */
    private func loginUsingCredentials(_ credentials: Credentials, promise: Promise<UserSession, SignInProviderError>) {
        accountProvider.login(email: credentials.username, password: credentials.password)
            .onSuccess { (userSession) in
                promise.success(userSession)
            }
            .onFailure { [weak self] (error) in
                switch error {
                case .unknown:
                    // TODO: We could potentially retry this request N times before we do this.
                    self?.loginUsingForm(promise: promise, reason: "Something went wrong on our end trying to validate your credentials. Please log in.")
                case .validation:
                    // Validation failed. Credentials are most likely out-of-date.
                    // Remove credentials and request that they login.
                    self?.keychainProvider.removeCredentials {
                        self?.loginUsingForm(promise: promise, reason: "Your credentials have become invalid since you last logged in.")
                    }
                }
            }
    }
    
    private func loginUsingForm(promise: Promise<UserSession, SignInProviderError>, reason: String? = nil) {
        let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle(for: AppSignInProvider.self))
        guard let vc = storyboard.instantiateInitialViewController() as? UINavigationController else {
            promise.failure(.unknown(GenericError()))
            return
        }
        guard let rootViewController = vc.topViewController as? SignInViewController else {
            promise.failure(.unknown(GenericError()))
            return
        }
        
        viewController = rootViewController
        rootViewController.delegate = self
        // TODO: Configure the `reason` with the view controller.
        presenterProvider.present(vc, completion: nil)
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
        viewController?.dismiss(animated: true) { [weak self] in
            self?.promise?.failure(.userCanceledLogin)
            self?.promise = nil
        }
    }
}
