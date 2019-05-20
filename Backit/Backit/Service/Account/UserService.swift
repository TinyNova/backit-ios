import BrightFutures
import Foundation

class UserService: UserProvider {

    private let service: Service
    
    init(service: Service) {
        self.service = service
    }
    
    func user() -> Future<User, UserProviderError> {
        let endpoint = UserAccountEndpoint()
        
        return service.request(endpoint)
            .mapError { error -> UserProviderError in
                return .unknown(error)
            }
            .flatMap { (response) -> Future<User, UserProviderError> in
                guard response.message == nil else {
                    return Future(error: .notLoggedIn)
                }
                return Future(value: User(avatarUrl: response.avatar, username: response.userName))
            }
    }
}
