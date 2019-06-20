/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

class AppExternalSignInProvider: ExternalSignInProvider {
    
    let urlSession: URLSession
    let accountProvider: AccountProvider
    let pageProvider: PageProvider
    let presenterProvider: PresenterProvider
    
    var promise: Promise<UserSession, ExternalSignInProviderError>?
    var profile: ExternalUserProfile?
    
    init(urlSession: URLSession, accountProvider: AccountProvider, pageProvider: PageProvider, presenterProvider: PresenterProvider) {
        self.urlSession = urlSession
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
                    
                    // Used later to upload avatar
                    sself.profile = profile
                    
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
        guard let promise = promise else {
            return
        }
        guard let avatarUrl = profile?.avatarUrl else {
            return promise.success(userSession)
        }
        
        log.i("Uploading avatar")
        
        let task = urlSession.dataTask(with: avatarUrl) { [weak self] (data, response, error) in
            if let error = error {
                log.w("Failed to upload avatar \(error)")
                return promise.success(userSession)
            }
            guard let data = data else {
                log.w("ata provided is empty")
                return promise.success(userSession)
            }
            guard let image = UIImage(data: data) else {
                log.w("Image could not be created from data")
                return promise.success(userSession)
            }
            
            self?.accountProvider.uploadAvatar(image: image)
                .onSuccess { _ in
                    log.i("Successfully uploaded the avatar")
                }
                .onFailure { (error) in
                    log.e("Failed to upload the avatar: \(String(describing: error))")
                }
                .onComplete { (result) in
                    promise.success(userSession)
                }
        }
        task.resume()
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
