import BrightFutures
import Foundation

typealias FacebookAccessToken = String

enum FacebookProviderError: Error {
    case facebook(Error)
    case failedToPresent
    case failedToLogin
}

protocol FacebookProvider {
    func login() -> Future<
        FacebookAccessToken, FacebookProviderError>
}
