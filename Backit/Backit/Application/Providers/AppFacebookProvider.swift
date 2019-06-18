/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import FacebookCore
import FBSDKLoginKit
import Foundation

class AppFacebookProvider: FacebookProvider {
    
    let presenterProvider: PresenterProvider
    
    var promise: Promise<FacebookAccessToken, FacebookProviderError>?
    
    init(presenterProvider: PresenterProvider) {
        self.presenterProvider = presenterProvider
    }
    
    func login() -> Future<FacebookAccessToken, FacebookProviderError> {
        if let promise = promise {
            return promise.future
        }
        
        guard let viewController = presenterProvider.viewController else {
            return Future(error: .failedToPresent)
        }
        
        let promise = Promise<FacebookAccessToken, FacebookProviderError>()
        self.promise = promise
        
        let loginManager = LoginManager()
        let permissions: [String] = [
            Permission.publicProfile.name,
            Permission.email.name
        ]
        loginManager.logIn(permissions: permissions, from: viewController) { (result, facebookError) in
            guard let token = result?.token?.tokenString else {
                let error: FacebookProviderError
                if let facebookError = facebookError {
                    error = .facebook(facebookError)
                }
                else {
                    error = .failedToLogin
                }
                return promise.failure(error)
            }
            
            promise.success(token)
        }
        
        _ = promise.future.andThen { [weak self] (result) in
            self?.promise = nil
        }
        
        return promise.future
    }
    
    func logout() -> Future<IgnorableValue, FacebookProviderError> {
        let loginManager = LoginManager()
        loginManager.logOut()
        return Future(value: IgnorableValue())
    }
}
