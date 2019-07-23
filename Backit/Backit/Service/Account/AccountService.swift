/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import CoreLocation
import Foundation
import UIKit

class AccountService: AccountProvider {
    
    private let service: Service
    private let sessionStream: UserSessionStreamer
    private let avatarStream: UserAvatarStreamer
    private let amazonService: AmazonService
    
    init(service: Service, sessionStream: UserSessionStreamer, avatarStream: UserAvatarStreamer, amazonService: AmazonService) {
        self.service = service
        self.sessionStream = sessionStream
        self.avatarStream = avatarStream
        self.amazonService = amazonService
    }
    
    func health() -> Future<AccountServiceHealth, AccountProviderError> {
        let endpoint = AccountHealthEndpoint()
        
        return service.request(endpoint)
            .mapError { (error) -> AccountProviderError in
                return .generic(error)
            }
            .flatMap { (response) -> Future<AccountServiceHealth, AccountProviderError> in
                let health = AccountServiceHealth(environment: response.env ?? "", services: response.services ?? [String: Bool]())
                return Future(value: health)
            }
    }
    
    func login(email: String, password: String) -> Future<UserSession, AccountProviderError> {
        let endpoint = LoginEndpoint(postBody: [
            .email(email),
            .password(password)
        ])
        
        return service.request(endpoint)
            .mapError { (error) -> AccountProviderError in
                return .generic(error)
            }
            .flatMap { (response) -> Future<UserSession, AccountProviderError> in
                guard let accountId = response.accountId,
                      let csrfToken = response.csrfToken,
                      let token = response.token,
                      let refreshToken = response.refreshToken else {
                    return Future(error: validationError(message: response.message, validation: response.validation))
                }
                return Future(value: UserSession(accountId: accountId, csrfToken: csrfToken, token: token, refreshToken: refreshToken))
            }
            .onSuccess { [weak self] (userSession) in
                self?.sessionStream.emit(userSession: userSession)
            }
    }
    
    func externalLogin(accessToken: String, provider: String) -> Future<ExternalAccount, AccountProviderError> {
        let endpoint = ExternalLoginEndpoint(postBody: [
            .accessToken(accessToken),
            .provider(provider)
        ])
        
        return service.request(endpoint)
            .mapError { (error) -> AccountProviderError in
                return .generic(error)
            }
            .flatMap { [weak self] (response) -> Future<ExternalAccount, AccountProviderError> in
                if let signupToken = response.signupToken {
                    var avatarUrl: URL?
                    if let avatar = response.providerUser?.avatar,
                       let url = URL(string: avatar) {
                        avatarUrl = url
                    }
                    return Future(value: .newUser(
                        signupToken: signupToken,
                        profile: ExternalUserProfile(
                            type: ExternalUserProvider.make(from: response.providerUser?.id),
                            id: response.providerUser?.id,
                            firstName: response.providerUser?.firstName,
                            lastName: response.providerUser?.lastName,
                            email: response.providerUser?.email,
                            avatarUrl: avatarUrl
                        )
                    ))
                }
                if let accountId = response.accountId,
                   let csrfToken = response.csrfToken,
                   let token = response.token,
                   let refreshToken = response.refreshToken {
                    let userSession = UserSession(
                        accountId: accountId,
                        csrfToken: csrfToken,
                        token: token,
                        refreshToken: refreshToken
                    )
                    self?.sessionStream.emit(userSession: userSession)
                    return Future(value: .existingUser(userSession))
                }

                return Future(error: validationError(message: response.message, validation: response.validation))
            }
    }
    
    func createExternalAccount(email: String, username: String, subscribe: Bool, signupToken: String) -> Future<UserSession, AccountProviderError> {
        let endpoint = CreateExternalAccountEndpoint(postBody: [
            .email(email),
            .userName(username),
            .signupToken(signupToken),
            .subscribe(subscribe)
        ])
        
        return service.request(endpoint)
            .mapError { (error) -> AccountProviderError in
                return .generic(error)
            }
            .flatMap { response -> Future<UserSession, AccountProviderError> in
                guard let accountId = response.accountId,
                      let csrfToken = response.csrfToken,
                      let token = response.token,
                      let refreshToken = response.refreshToken else {
                    return Future(error: validationError(message: response.message, validation: response.validation))
                }
                return Future(value: UserSession(accountId: accountId, csrfToken: csrfToken, token: token, refreshToken: refreshToken))
            }
            .onSuccess { [weak self] (userSession) in
                self?.sessionStream.emit(userSession: userSession)
            }
    }
    
    func usernameAvailable(username: String) -> Future<UsernameAvailable, AccountProviderError> {
        let endpoint = UsernameAvailabilityEndpoint(pathParameters: [
            .userName(username)
        ])
        
        return service.request(endpoint)
            .mapError { (error) -> AccountProviderError in
                return .generic(error)
            }
            .flatMap { (result) -> Future<Bool, AccountProviderError> in
                return Future(value: !result.found)
            }
    }
        
    func createAccount(email: String, username: String, password: String, repeatPassword: String, firstName: String?, lastName: String?, subscribe: Bool) -> Future<UserSession, AccountProviderError> {
        let endpoint = CreateAccountEndpoint(postBody: [
            .email(email),
            .userName(username),
            .firstName(firstName),
            .lastName(lastName),
            .password(password),
            .repeatPassword(repeatPassword),
            .subscribe(subscribe)
        ])
        
        return service.request(endpoint)
            .mapError { (error) -> AccountProviderError in
                return .generic(error)
            }
            .flatMap { (response) -> Future<UserSession, AccountProviderError> in
                guard let accountId = response.accountId,
                      let csrfToken = response.csrfToken,
                      let token = response.token,
                      let refreshToken = response.refreshToken else {
                    return Future(error: validationError(message: response.message, validation: response.validation))
                }
                return Future(value: UserSession(accountId: accountId, csrfToken: csrfToken, token: token, refreshToken: refreshToken))
            }
            .onSuccess { [weak self] (userSession) in
                self?.sessionStream.emit(userSession: userSession)
            }
    }

    func resetPassword(email: String) -> Future<IgnorableValue, AccountProviderError> {
        let endpoint = RecoverPasswordEndpoint(postBody: [
            .email(email)
        ])
        
        return service.request(endpoint)
            .mapError { (error) -> AccountProviderError in
                return .generic(GenericError())
            }
            .flatMap { (response) -> Future<IgnorableValue, AccountProviderError> in
                return Future(value: IgnorableValue())
            }
    }
        
    func silentlyReauthenticate(accountId: String, refreshToken: String) -> Future<UserSession, AccountProviderError> {
        // FIXME: This endpoint may be called more than once at a time.
        let endpoint = RefreshTokenEndpoint(postBody: [
            .accountId(accountId),
            .refreshToken(refreshToken)
        ])
        
        return service.request(endpoint)
            .mapError { (error) -> AccountProviderError in
                return .generic(error)
            }
            .flatMap { (response) -> Future<UserSession, AccountProviderError> in
                guard let accountId = response.accountId,
                      let csrfToken = response.csrfToken,
                      let token = response.token,
                      let refreshToken = response.refreshToken else {
                    return Future(error: validationError(message: response.message, validation: response.validation))
                }
                return Future(value: UserSession(accountId: accountId, csrfToken: csrfToken, token: token, refreshToken: refreshToken))
            }
            .onSuccess { [weak self] (userSession) in
                self?.sessionStream.emit(userSession: userSession)
            }
    }
    
    func logout() -> Future<IgnorableValue, AccountProviderError> {
        sessionStream.emit(userSession: nil)
        return Future(value: IgnorableValue())
    }
    
    func uploadAvatar(image: UIImage) -> Future<IgnorableValue, AccountProviderError> {
        let endpoint = UploadAvatarEndpoint()
        
        avatarStream.emit(image: image, state: .uploading)
        
        return service.request(endpoint)
            .mapError { (error) -> AccountProviderError in
                return .generic(error)
            }
            .flatMap { (response) -> Future<S3UploadFile, AccountProviderError> in
                if let error = response.error {
                    return Future(error: .thirdParty(StringError(error: error)))
                }
                guard let bucket = response.bucket,
                      let acl = response.acl,
                      let awsKey = response.awsKey,
                      let key = response.key,
                      let policy = response.policy,
                      let signature = response.signature else {
                    return Future(error: .failedToDecode(type: "UploadAvatarEndpoint.ResponseType"))
                }
                
                let s3file = S3UploadFile(
                    bucket: bucket,
                    acl: acl,
                    awsKey: awsKey,
                    key: key,
                    policy: policy,
                    signature: signature
                )
                return Future(value: s3file)
            }
            .flatMap { [amazonService] (s3file) -> Future<IgnorableValue, AccountProviderError> in
                return amazonService.upload(file: s3file, image: image)
                    .mapError(AccountProviderError.make(from:))
            }
            .onSuccess { [weak self] _ in
                self?.avatarStream.emit(image: image, state: .uploaded)
            }
            .onFailure { [weak self] _ in
                self?.avatarStream.emit(image: image, state: .failed)
            }
    }
}

private func validationError(message: String?, validation: [String: [String]]?) -> AccountProviderError {
    var fields = [AccountValidationField: [String]]()
    validation?.forEach { (record: (key: String, value: [String])) in
        fields[AccountValidationField.map(record.key)] = record.value
    }
    return .validation(message: message, fields: fields)
}

extension AccountValidationField {
    static func map(_ value: String) -> AccountValidationField {
        switch value.lowercased() {
        case "username":
            return .username
        case "email":
            return .email
        case "firstname":
            return .firstName
        case "lastname":
            return .lastName
        case "password":
            return .password
        case "refreshtoken":
            return .refreshToken
        default:
            log.w("Failed to map `AccountValidatedField` \(value)")
            return .unknown
        }
    }
}

extension AccountProviderError {
    static func make(from error: AmazonServiceError) -> AccountProviderError {
        return .thirdParty(error)
    }
}

extension ExternalUserProvider {
    static func make(from provider: String?) -> ExternalUserProvider? {
        guard let provider = provider else {
            return nil
        }
        
        switch provider.lowercased() {
        case "facebook":
            return .facebook
        case "google":
            return .google
        default:
            return nil
        }
    }
}
