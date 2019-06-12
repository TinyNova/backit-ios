/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import FacebookCore
import FacebookLogin
import FBSDKLoginKit
import Foundation

private struct FacebookResponse: Decodable {
    struct Picture: Decodable {
        struct PictureData: Decodable {
            let height: Float
            let is_silhouette: Bool
            let url: String
        }
        
        let data: PictureData?
    }
    
    let id: String?
    let email: String?
    let first_name: String?
    let last_name: String?
    let picture: Picture?
}

class AppFacebookProvider: FacebookProvider {
    
    let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider) {
        self.presenterProvider = presenterProvider
    }
    
    func login() -> Future<FacebookSession, FacebookProviderError> {
        guard let viewController = presenterProvider.viewController else {
            return Future(error: .failedToPresent)
        }
        
        let promise = Promise<FacebookSession, FacebookProviderError>()
        
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
            
            let conn = GraphRequestConnection()
            conn.add(GraphRequest(graphPath: "/me", parameters: ["fields": "id,email,first_name,last_name,picture"])) { (conn, response, error) in
                if let error = error {
                    return promise.failure(.facebook(error))
                }
                guard let dict = response as? [String: Any],
                      let json = try? JSONSerialization.data(withJSONObject: dict, options: []),
                      let user = try? JSONDecoder().decode(FacebookResponse.self, from: json) else {
                    return promise.failure(.failedToDecodeProfile)
                }
                var profileUrl: URL?
                if let urlString = user.picture?.data?.url, let url = URL(string: urlString) {
                    profileUrl = url
                }
                
                let session = FacebookSession(
                    token: token,
                    user: FacebookUser(
                        id: user.id ?? "UNKNOWN_ID",
                        email: user.email,
                        firstName: user.first_name,
                        lastName: user.last_name,
                        profileUrl: profileUrl
                    )
                )
                promise.success(session)
            }
            conn.start()
        }
        
        return promise.future
    }
}
