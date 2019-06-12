import BrightFutures
import Foundation

struct FacebookSession {
    let token: String
    let user: FacebookUser
}

struct FacebookUser {    
    let id: String
    let email: String?
    let firstName: String?
    let lastName: String?
    let profileUrl: URL?
}

enum FacebookProviderError: Error {
    case facebook(Error)
    case failedToPresent
    case failedToLogin
    case failedToDecodeProfile
}

protocol FacebookProvider {
    func login() -> Future<
        FacebookSession, FacebookProviderError>
}
