/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation
import KeychainAccess

private enum Constant {
    static let service = "com.backit.backit.service"
    static let credentials = "com.backit.backit.service.credentials"
    static let userSession = "com.backit.backit.service.usersession"
}

class AppKeychainProvider: KeychainProvider {

    let dispatchQueue: DispatchQueue

    init(dispatchQueue: DispatchQueue) {
        self.dispatchQueue = dispatchQueue
    }

    func saveUserSession(_ userSession: UserSession) -> Future<IgnorableValue, KeychainProviderError> {
        log.i("Saving session")
        guard let encodedValue = userSession.asJsonString else {
            log.e("Failed to encode session")
            return Future(error: .failedToEncode)
        }

        let promise = Promise<IgnorableValue, KeychainProviderError>()
        let keychain = Keychain(service: Constant.service)

        dispatchQueue.async {
            do {
                try keychain.set(encodedValue, key: Constant.userSession)
                promise.success(IgnorableValue())
                log.i("Saved session")
            }
            catch {
                promise.failure(.unknown(error))
                log.e(error)
            }
        }

        return promise.future
    }

    func userSession() -> Future<UserSession, KeychainProviderError> {
        log.i("Getting session")

        let promise = Promise<UserSession, KeychainProviderError>()
        let keychain = Keychain(service: Constant.service)

        dispatchQueue.async {
            do {
                let encodedValue = try keychain.get(Constant.userSession)

                guard let data = encodedValue?.data(using: .utf8),
                      let userSession = try? JSONDecoder().decode(UserSession.self, from: data) else {
                    log.e("Failed to decode session")
                    promise.failure(.failedToDecode)
                    try keychain.removeAll()
                    return
                }

                promise.success(userSession)
                log.i("Successfully retrieved session")
            } catch let error {
                promise.failure(.unknown(error))
                log.e(error)
            }
        }

        return promise.future
    }

    func saveCredentials(_ credentials: Credentials?) -> Future<IgnorableValue, KeychainProviderError> {
        guard let credentials = credentials else {
            log.i("No credentials to save - 3rd party login?")
            return Future(error: .credentialsNotProvided)
        }
        
        log.i("Saving credentials")
        guard let encodedCredentials = credentials.asJsonString else {
            return Future(error: .failedToEncode)
        }
        
        let promise = Promise<IgnorableValue, KeychainProviderError>()
        let keychain = Keychain(service: Constant.service)

        dispatchQueue.async {
            do {
                try keychain
                    .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
                    .set(encodedCredentials, key: Constant.credentials)
                promise.success(IgnorableValue())
                log.i("Saved credentials")
            }
            catch {
                promise.failure(.unknown(error))
                log.e(error)
            }
        }
        
        return promise.future
    }

    func credentials() -> Future<Credentials, KeychainProviderError> {
        log.i("Getting credentials")
        // TODO: Only get credentials if the user is using biometrics
        
        let promise = Promise<Credentials, KeychainProviderError>()
        let keychain = Keychain(service: Constant.service)

        dispatchQueue.async {
            do {
                let encodedCredentials = try keychain
                    .authenticationPrompt("Authenticate to login to your account")
                    .get(Constant.credentials)

                guard let data = encodedCredentials?.data(using: .utf8) else {
                    promise.failure(.noStoredCredentials)
                    return log.i("No stored credentials")
                }
                guard let credentials = try? JSONDecoder().decode(Credentials.self, from: data) else {
                    promise.failure(.failedToDecode)
                    try? keychain.removeAll()
                    return log.e("Failed to decode credentials")
                }

                promise.success(credentials)
                log.i("Successfully retrieved credentials")
            }
            catch {
                promise.failure(.unknown(error))
                log.e(error)
            }
        }
        
        return promise.future
    }
    
    func removeAll() -> Future<IgnorableValue, KeychainProviderError> {
        log.i("Removing credentials")
        let keychain = Keychain(service: Constant.service)

        do {
            try keychain.remove(Constant.credentials)
            try keychain.remove(Constant.userSession)
            log.i("Successfully removed credentials")
            return Future(value: IgnorableValue())
        }
        catch {
            log.e(error)
            return Future(error: .unknown(error))
        }
    }
}
