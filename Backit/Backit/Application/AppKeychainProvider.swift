import Foundation
import KeychainAccess

private enum Constant {
    static let service = "com.backit.Backit.credentials"
    static let key = "com.backit.Backit.credentials.key"
}

class AppKeychainProvider: KeychainProvider {
    func saveCredentials(_ credentials: Credentials, completion: @escaping (KeychainProviderError?) -> Void) {
        let keychain = Keychain(service: Constant.service)

        DispatchQueue.global().async {
            do {
                try keychain
                    .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
                    .set("\(credentials.username):\(credentials.password)", key: Constant.key)
                completion(nil)
            } catch let error {
                completion(.unknown(error))
            }
        }
    }
    
    func getCredentials(_ completion: @escaping (Credentials?, KeychainProviderError?) -> Void) {
        // TODO: Only get credentials if the user is using biometrics
        
        let keychain = Keychain(service: Constant.service)

        DispatchQueue.global().async {
            do {
                let credentialsString = try keychain
                    .authenticationPrompt("Authenticate to login to your account")
                    .get(Constant.key)

                guard let parts = credentialsString?.split(separator: ":"), parts.count == 2 else {
                    return completion(nil, .credentialsCorrupted)
                }

                let credentials = Credentials(username: String(parts[0]), password: String(parts[1]))
                completion(credentials, nil)
            } catch let error {
                completion(nil, .unknown(error))
            }
        }
    }
    
    func removeCredentials(_ completion: @escaping (KeychainProviderError?) -> Void) {
        let keychain = Keychain(service: Constant.service)

        do {
            try keychain.remove(Constant.key)
            completion(nil)
        } catch let error {
            completion(.unknown(error))
        }
    }
}
