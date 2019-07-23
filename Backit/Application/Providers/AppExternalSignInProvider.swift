/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

import BKFoundation

class AppExternalSignInProvider: ExternalSignInProvider {
    
    weak var delegate: ExternalSignInProviderDelegate?
    
    private let accountProvider: AccountProvider
    private let pageProvider: PageProvider
    
    private var promise: Promise<UserSession, ExternalSignInProviderError>?
    
    init(accountProvider: AccountProvider, pageProvider: PageProvider) {
        self.accountProvider = accountProvider
        self.pageProvider = pageProvider
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
                    guard let delegate = sself.delegate else {
                        log.e("Can not finish account creation. `ExternalSignInProvider.delegate` has not been set!")
                        return promise.failure(.failedToFinishAccountCreation)
                    }
                    guard let vc = sself.pageProvider.finalizeAccountCreation() else {
                        return promise.failure(.generic(StoryboardError()))
                    }
                    
                    vc.delegate = sself
                    vc.configure(signupToken: signupToken, profile: profile)
                    
                    delegate.present(vc)
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
