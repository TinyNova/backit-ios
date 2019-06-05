import BrightFutures
import Foundation
import KeychainAccess

private enum Constant {
    static let service = "com.backit.Backit.credentials"
    static let key = "com.backit.Backit.credentials.key"
}

class AppKeychainProvider: KeychainProvider {
    
    func saveCredentials(_ credentials: Credentials) -> Future<IgnorableValue, KeychainProviderError> {
        guard let encodedCredentials = credentials.asJsonString else {
            return Future(error: .failedToEncodeCredentials)
        }
        
        let promise = Promise<IgnorableValue, KeychainProviderError>()
        let keychain = Keychain(service: Constant.service)

        DispatchQueue.global().async {
            do {
                try keychain
                    .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
                    .set(encodedCredentials, key: Constant.key)
                promise.success(IgnorableValue())
            } catch let error {
                promise.failure(.unknown(error))
            }
        }
        
        return promise.future
    }

    func getCredentials() -> Future<Credentials, KeychainProviderError> {
        // TODO: Only get credentials if the user is using biometrics
        
        let promise = Promise<Credentials, KeychainProviderError>()
        let keychain = Keychain(service: Constant.service)

        DispatchQueue.global().async {
            do {
                let encodedCredentials = try keychain
                    .authenticationPrompt("Authenticate to login to your account")
                    .get(Constant.key)

                guard let data = encodedCredentials?.data(using: .utf8),
                      let credentials = try? JSONDecoder().decode(Credentials.self, from: data) else {
                        promise.failure(.failedToDecodeCredentials)
                    try keychain.removeAll()
                    return
                }

                promise.success(credentials)
            } catch let error {
                promise.failure(.unknown(error))
            }
        }
        
        return promise.future
    }
    
    func removeCredentials() -> Future<IgnorableValue, KeychainProviderError> {
        let keychain = Keychain(service: Constant.service)

        do {
            try keychain.remove(Constant.key)
            return Future(value: IgnorableValue())
        } catch let error {
            return Future(error: .unknown(error))
        }
    }
}
