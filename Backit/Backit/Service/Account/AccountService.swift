/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import CoreLocation
import Foundation

class AccountService: AccountProvider {
    
    private let service: Service
    private let sessionProvider: SessionProvider
    private let amazonService: AmazonService
    
    init(service: Service, sessionProvider: SessionProvider, amazonService: AmazonService) {
        self.service = service
        self.sessionProvider = sessionProvider
        self.amazonService = amazonService
    }
    
    func login(email: String, password: String) -> Future<UserSession, AccountProviderError> {
        let endpoint = LoginEndpoint(postBody: [
            .email(email),
            .password(password)
        ])
        
        return service.request(endpoint)
            .mapError { (error) -> AccountProviderError in
                return .unknown(error)
            }
            .flatMap { (response) -> Future<UserSession, AccountProviderError> in
                guard let accountId = response.accountId,
                      let csrfToken = response.csrfToken,
                      let token = response.token,
                      let refreshToken = response.refreshToken else {
                    // TODO: Map `validation` errors
                    return Future(error: .validation([:]))
                }
                return Future(value: UserSession(accountId: accountId, csrfToken: csrfToken, token: token, refreshToken: refreshToken))
            }
            .onSuccess { [weak self] (userSession) in
                self?.sessionProvider.emit(userSession: userSession)
            }
    }
        
    func createAccount(email: String, username: String, password: String, repeatPassword: String, firstName: String, lastName: String, subscribe: Bool) -> Future<UserSession, AccountProviderError> {
        let endpoint = CreateAccountEndpoint(postBody: .init(
            email: email,
            userName: username,
            firstName: firstName,
            lastName: lastName,
            password: password,
            repeatPassword: repeatPassword,
            subscribe: subscribe
        ))
        
        return service.request(endpoint)
            .mapError { (error) -> AccountProviderError in
                return .unknown(error)
            }
            .flatMap { (response) -> Future<UserSession, AccountProviderError> in
                guard let accountId = response.accountId,
                      let csrfToken = response.csrfToken,
                      let token = response.token,
                      let refreshToken = response.refreshToken else {
                    // TODO: Map `validation` errors
                    return Future(error: .validation([:]))
                }
                return Future(value: UserSession(accountId: accountId, csrfToken: csrfToken, token: token, refreshToken: refreshToken))
            }
            .onSuccess { [weak self] (userSession) in
                self?.sessionProvider.emit(userSession: userSession)
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
                return .unknown(error)
            }
            .flatMap { (response) -> Future<UserSession, AccountProviderError> in
                guard let accountId = response.accountId,
                      let csrfToken = response.csrfToken,
                      let token = response.token,
                      let refreshToken = response.refreshToken else {
                    // TODO: Map `validation` errors
                    return Future(error: .validation([:]))
                }
                return Future(value: UserSession(accountId: accountId, csrfToken: csrfToken, token: token, refreshToken: refreshToken))
            }
            .onSuccess { [weak self] (userSession) in
                self?.sessionProvider.emit(userSession: userSession)
            }
    }
    
    func logout() -> Future<IgnorableValue, AccountProviderError> {
        sessionProvider.emit(userSession: nil)
        return Future(value: IgnorableValue())
    }
    
    func uploadAvatar(image: UIImage) -> Future<IgnorableValue, AccountProviderError> {
        let endpoint = UploadAvatarEndpoint()
        
        return service.request(endpoint)
            .mapError { (error) -> AccountProviderError in
                return .unknown(error)
            }
            .flatMap { (response) -> Future<S3UploadFile, AccountProviderError> in
                if let error = response.error {
                    return Future(error: .service(error))
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
                    filename: "avatar-image",
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
    }
}

extension AccountProviderError {
    static func make(from error: AmazonServiceError) -> AccountProviderError {
        return .unknown(error)
    }
}
