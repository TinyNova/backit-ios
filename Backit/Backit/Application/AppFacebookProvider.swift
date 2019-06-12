import BrightFutures
import FacebookLogin
import FBSDKLoginKit
import Foundation

class AppFacebookProvider: FacebookProvider {
    
    let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider) {
        self.presenterProvider = presenterProvider
    }
    
    func login() -> Future<FacebookAccessToken, FacebookProviderError> {
        guard let viewController = presenterProvider.viewController else {
            return Future(error: .failedToPresent)
        }
        
        let promise = Promise<FacebookAccessToken, FacebookProviderError>()
        
        let loginManager = LoginManager()
        // I'm looking in FacebookCore.Permission for these values...
        let permissions: [String] = [
            "publicProfile"
        ]
        loginManager.logIn(permissions: permissions, from: viewController) { (result, facebookError) in
            guard let result = result else {
                let error: FacebookProviderError
                if let facebookError = facebookError {
                    error = .facebook(facebookError)
                }
                else {
                    error = .failedToLogin
                }
                return promise.failure(error)
            }
            
            print("Result: \(result)")
        }
        
        return promise.future
    }
}
