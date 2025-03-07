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
    let pageProvider: PageProvider
    let facebookProvider: FacebookProvider
    let googleProvider: GoogleProvider
    
    var promise: Promise<UserSession, SignInProviderError>?
    var viewController: SignInViewController?
    
    init(keychainProvider: KeychainProvider, accountProvider: AccountProvider, presenterProvider: PresenterProvider, pageProvider: PageProvider, facebookProvider: FacebookProvider, googleProvider: GoogleProvider) {
        self.keychainProvider = keychainProvider
        self.accountProvider = accountProvider
        self.presenterProvider = presenterProvider
        self.pageProvider = pageProvider
        self.facebookProvider = facebookProvider
        self.googleProvider = googleProvider
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
        
        keychainProvider.credentials()
            .onSuccess { [weak self] credentials in
                // Login using credentials from keychain
                self?.loginUsingCredentials(credentials, promise: promise)
            }
            .onFailure { [weak self] (error) in
                // Challenge user with login form
                self?.loginUsingForm(promise: promise)
            }
        
        _ = promise.future.andThen { [weak self] (result) in
            self?.promise = nil
        }
        
        return promise.future
    }
    
    func logout() -> Future<IgnorableValue, SignInProviderError> {
        let futures: [Future<IgnorableValue, SignInProviderError>] = [
            accountProvider.logout().mapError { error -> SignInProviderError in
                return .generic(error)
            },
            keychainProvider.removeAll().mapError { error -> SignInProviderError in
                return .generic(error)
            },
            
            // External providers
            facebookProvider.logout().mapError { error -> SignInProviderError in
                return .generic(error)
            },
            googleProvider.logout().mapError { error -> SignInProviderError in
                return .generic(error)
            }
        ]
        
        return futures.sequence()
            .map { values -> IgnorableValue in
                return IgnorableValue()
            }
    }
    
    // MARK: Private methods
    
    /**
     * Attempt to login the user with the stored credentials.
     *
     * If the process is successful, the credentials are updated with the new token.
     *
     * If the process fails because of:
     *  - networking issue, then the user will be asked to login.
     *  - validation, then credentials will be removed and the user will be asked to login.
     */
    private func loginUsingCredentials(_ credentials: Credentials, promise: Promise<UserSession, SignInProviderError>) {
        accountProvider.login(email: credentials.email, password: credentials.password)
            .onSuccess { [weak self] (userSession) in
                self?.keychainProvider.saveUserSession(userSession).onComplete { _ /* TODO: Ignore Error for now */ in
                    promise.success(userSession)
                }
            }
            .onFailure { [weak self] (error) in
                switch error {
                case .thirdParty,
                     .failedToDecode,
                     .generic:
                    // TODO: We could potentially retry this request N times before we do this.
                    self?.loginUsingForm(promise: promise, reason: "Something went wrong on our end trying to validate your credentials. Please log in.")
                case .validation:
                    // Validation failed. Credentials are most likely out-of-date.
                    // Remove credentials and request that they login.
                    self?.keychainProvider.removeAll().onComplete { _ in /* Ignore error */
                        self?.loginUsingForm(promise: promise, reason: "Your credentials have become invalid since you last logged in.")
                    }
                }
            }
    }
    
    private func loginUsingForm(promise: Promise<UserSession, SignInProviderError>, reason: String? = nil) {
        guard let vc = pageProvider.signIn() else {
            promise.failure(.generic(GenericError()))
            return
        }
        guard let rootViewController = vc.topViewController as? SignInViewController else {
            promise.failure(.generic(GenericError()))
            return
        }
        
        viewController = rootViewController
        rootViewController.delegate = self
        // TODO: Configure the `reason` with the view controller.
        presenterProvider.present(vc, completion: nil)
    }
}

extension AppSignInProvider: SignInViewControllerDelegate {
    func didSignIn(credentials: Credentials?, userSession: UserSession) {
        // FIXME: Only save credentials to the device if the user requested to do so. A new option must be provided that lets us know if credentials should be saved.
        let futures: [Future<IgnorableValue, KeychainProviderError>] = [
            keychainProvider.saveUserSession(userSession),
            keychainProvider.saveCredentials(credentials)
        ]
        futures.sequence().onComplete { [weak self] _ in
            self?.promise?.success(userSession)
            self?.viewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func userCancelled() {
        promise?.failure(.userCanceledLogin)
        viewController?.dismiss(animated: true, completion: nil)
    }
}
