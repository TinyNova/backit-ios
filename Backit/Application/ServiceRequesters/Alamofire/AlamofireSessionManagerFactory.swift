/**
 Provides definition of a request made to a service.
 
 License: MIT
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Alamofire
import Foundation

class AlamofireSessionManagerFactory {
    
    static func makeDevelopment() -> SessionManager {
        let policies: [String: ServerTrustPolicy] = [
            "127.0.0.1:8443": .disableEvaluation
        ]
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        let manager = SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: policies)
        )

        manager.delegate.sessionDidReceiveChallenge = { (session, challenge) in
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                disposition = URLSession.AuthChallengeDisposition.useCredential
                credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            }
            else {
                if challenge.previousFailureCount > 0 {
                    disposition = .cancelAuthenticationChallenge
                }
                else {
                    credential = manager.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
                    if credential != nil {
                        disposition = .useCredential
                    }
                }
            }
            return (disposition, credential)
        }

        return manager
    }
    
    static func makeProduction() -> SessionManager {
        return SessionManager.default
    }
}
