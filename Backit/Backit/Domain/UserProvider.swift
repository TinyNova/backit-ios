import BrightFutures
import Foundation

enum UserProviderError: Error {
    case unknown(Error)
    case notLoggedIn
}

protocol UserProvider {
    func user() -> Future<User, UserProviderError>
}
