import Foundation
import KeychainAccess

private enum Constant {
    static let service = "com.backit.Backit.credentials"
    static let key = "com.backit.Backit.credentials.key"
}

class AppKeychainProvider: KeychainProvider {
    func saveCredentials(_ credentials: Credentials, completion: @escaping (KeychainProviderError?) -> Void) {
        guard let encodedCredentials = credentials.asJsonString else {
            completion(.failedToEncodeCredentials)
            return
        }
        let keychain = Keychain(service: Constant.service)

        DispatchQueue.global().async {
            do {
                try keychain
                    .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
                    .set(encodedCredentials, key: Constant.key)
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
                let encodedCredentials = try keychain
                    .authenticationPrompt("Authenticate to login to your account")
                    .get(Constant.key)

                guard let data = encodedCredentials?.data(using: .utf8),
                      let credentials = try? JSONDecoder().decode(Credentials.self, from: data) else {
                    completion(nil, .failedToDecodeCredentials)
                    try keychain.removeAll()
                    return
                }

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
