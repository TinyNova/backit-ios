/**
 *
 * https://developers.google.com/identity/sign-in/ios/sign-in?ver=swift
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import BrightFutures
import GoogleSignIn
import UIKit

class GoogleViewController: UIViewController {
    
}

@objc class AppGoogleProvider: NSObject, GoogleProvider {
    
    let presenterProvider: PresenterProvider
    
    private lazy var signIn: GIDSignIn? = {
        return GIDSignIn.sharedInstance()
    }()
    
    private var promise: Promise<GoogleAuthenticationToken, GoogleProviderError>?
    
    init(presenterProvider: PresenterProvider) {
        self.presenterProvider = presenterProvider
        super.init()
    }
    
    func appDidLaunch() {
        signIn?.clientID = "456554125427-g452q3cc0b9a6755k52r8n6crcnost2t.apps.googleusercontent.com"
        signIn?.delegate = self
    }
    
    func appDidOpen(url: URL, with options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return signIn?.handle(
            url as URL?
        ) ?? true
    }
    
    func login() -> Future<GoogleAuthenticationToken, GoogleProviderError> {
        if let promise = promise {
            return promise.future
        }
        
        let promise = Promise<GoogleAuthenticationToken, GoogleProviderError>()
        self.promise = promise
        
        DispatchQueue.main.async { [weak self] in
            self?.signIn?.delegate = self
            // TODO: Get the top-most view controller. The view controller who will be presenting this. And then I have to update the
            let vc = GoogleViewController()
            self?.signIn?.presentingViewController = vc
            self?.signIn?.signIn()
        }
        
        _ = promise.future.andThen { [weak self] (result) in
            self?.promise = nil
        }
        
        return promise.future
    }
    
    func logout() -> Future<IgnorableValue, GoogleProviderError> {
        signIn?.disconnect()
        signIn?.signOut()
        return Future(value: IgnorableValue())
    }
}

extension AppGoogleProvider: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard let promise = promise else {
            return
        }
        if let error = error {
            return promise.failure(.google(error))
        }
        
        // NOTE: there is also an `accessToken`. `idToken` is used in the tutorial and states directly that it can be sent to the server.
//        promise.success(user.authentication.idToken)
        promise.success(user.authentication.accessToken)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // TODO: Do something when the user disconnects with the app?
    }
}

//extension AppGoogleProvider: GIDSignInUIDelegate {
//    /// The user wants to sign in
//    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
//
//    }
//
//    /// Called when wanting to present a view to login
//    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
//        presenterProvider.present(viewController, completion: nil)
//    }
//
//    /// Called when user wants to dismiss the login
//    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
//        presenterProvider.dismiss(viewController, completion: nil)
//    }
//}
