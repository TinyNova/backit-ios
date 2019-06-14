/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

class AppExternalSignInProvider: ExternalSignInProvider {
    
    let accountProvider: AccountProvider
    let pageProvider: PageProvider
    let presenterProvider: PresenterProvider
    
    var promise: Promise<UserSession, ExternalSignInProviderError>?
    
    init(accountProvider: AccountProvider, pageProvider: PageProvider, presenterProvider: PresenterProvider) {
        self.accountProvider = accountProvider
        self.pageProvider = pageProvider
        self.presenterProvider = presenterProvider
    }
    
    func login(with accessToken: String, provider: ExternalSignInProviderType) -> Future<UserSession, ExternalSignInProviderError> {
        if let promise = promise {
            return promise.future
        }
        
        let promise = Promise<UserSession, ExternalSignInProviderError>()
        
        accountProvider.externalLogin(accessToken: accessToken, provider: provider.asString)
            .onSuccess { [weak self] (result) in
                switch result {
                case .existingUser(let userSession):
                    promise.success(userSession)
                case .newUser(let signupToken, let profile):
                    guard let sself = self else {
                        return promise.failure(.generic(WeakReferenceError()))
                    }
                    
                    let vc = sself.pageProvider.finalizeAccountCreation()
                    vc.delegate = sself
                    vc.configure(signupToken: signupToken, profile: profile)
                    sself.presenterProvider.push(vc)
                }
            }
            .onFailure { (error) in
                promise.failure(.failedToSignIn)
            }
        
        _ = promise.future.andThen { [weak self] (result) in
            self?.promise = nil
        }
        
        self.promise = promise
        return promise.future
    }
}

extension AppExternalSignInProvider: FinalizeAccountCreationViewControllerDelegate {
    
    func didCreateAccount(userSession: UserSession) {
        // TODO: Upload User's avatar
        promise?.success(userSession)
    }
}

private extension ExternalSignInProviderType {
    var asString: String {
        switch self {
        case .facebook:
            return "facebook"
        case .google:
            return "google"
        }
    }
}
