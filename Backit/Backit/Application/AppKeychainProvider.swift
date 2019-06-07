import BrightFutures
import Foundation
import KeychainAccess

private enum Constant {
    static let service = "com.backit.backit.service"
    static let credentials = "com.backit.backit.service.credentials"
    static let userSession = "com.backit.backit.service.usersession"
}

class AppKeychainProvider: KeychainProvider {
    
    func saveUserSession(_ userSession: UserSession) -> Future<IgnorableValue, KeychainProviderError> {
        print("INFO: Saving session...")
        guard let encodedValue = userSession.asJsonString else {
            return Future(error: .failedToEncodeCredentials)
        }

        let promise = Promise<IgnorableValue, KeychainProviderError>()
        let keychain = Keychain(service: Constant.service)

        DispatchQueue.global().async {
            do {
                try keychain
                    .set(encodedValue, key: Constant.userSession)
                promise.success(IgnorableValue())
            } catch let error {
                promise.failure(.unknown(error))
            }
        }

        return promise.future
    }

    func userSession() -> Future<UserSession, KeychainProviderError> {
        print("INFO: Getting session...")

        let promise = Promise<UserSession, KeychainProviderError>()
        let keychain = Keychain(service: Constant.service)

        DispatchQueue.global().async {
            do {
                let encodedValue = try keychain.get(Constant.userSession)

                guard let data = encodedValue?.data(using: .utf8),
                      let userSession = try? JSONDecoder().decode(UserSession.self, from: data) else {
                        promise.failure(.failedToDecodeCredentials)
                        try keychain.removeAll()
                    return
                }

                promise.success(userSession)
            } catch let error {
                promise.failure(.unknown(error))
            }
        }

        return promise.future
    }

    func saveCredentials(_ credentials: Credentials) -> Future<IgnorableValue, KeychainProviderError> {
        print("INFO: Saving credentials...")
        guard let encodedCredentials = credentials.asJsonString else {
            return Future(error: .failedToEncodeCredentials)
        }
        
        let promise = Promise<IgnorableValue, KeychainProviderError>()
        let keychain = Keychain(service: Constant.service)

        DispatchQueue.global().async {
            do {
                try keychain
                    .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
                    .set(encodedCredentials, key: Constant.credentials)
                promise.success(IgnorableValue())
            } catch let error {
                promise.failure(.unknown(error))
            }
        }
        
        return promise.future
    }

    func credentials() -> Future<Credentials, KeychainProviderError> {
        print("INFO: Getting credentials...")
        // TODO: Only get credentials if the user is using biometrics
        
        let promise = Promise<Credentials, KeychainProviderError>()
        let keychain = Keychain(service: Constant.service)

        DispatchQueue.global().async {
            do {
                let encodedCredentials = try keychain
                    .authenticationPrompt("Authenticate to login to your account")
                    .get(Constant.credentials)

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
    
    func removeAll() -> Future<IgnorableValue, KeychainProviderError> {
        print("INFO: Removing credentials...")
        let keychain = Keychain(service: Constant.service)

        do {
            try keychain.remove(Constant.credentials)
            try keychain.remove(Constant.userSession)
            return Future(value: IgnorableValue())
        } catch let error {
            return Future(error: .unknown(error))
        }
    }
}
