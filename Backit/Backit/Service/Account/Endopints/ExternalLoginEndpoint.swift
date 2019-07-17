/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

struct ExternalLoginEndpoint: ServiceEndpoint {
        
    struct ResponseType: Decodable {
        struct ProviderUser: Decodable {
            let provider: String
            let id: String
            let email: String?
            let avatar: String?
            let firstName: String?
            let lastName: String?
        }
        
        /// Success Response (202)
        let signupToken: String?
        let providerUser: ProviderUser?
        
        /// Success Response (200)
        let csrfToken: String?
        let refreshToken: String?
        let accountId: String?
        let token: String?
        
        /// Failure Response
        let message: String?
        let validation: [String: [String]]? // <- I'm not sure if this comes back or not
    }

    enum Header { }
    enum PathParameter { }
    enum QueryParameter { }
    enum PostParameter: ServiceParameter {
        case accessToken(String)
        /// `provider` options are: `facebook`, `google`
        case provider(String)
    }
    typealias PostBody = [PostParameter]

    var type: ServiceRequestType = .post
    var httpBodyEncodingStrategy: HTTPBodyEncodingStrategy = .keyValue
    var endpoints: Endpoints = [
        .dev: "https://127.0.0.1:8443/account/login/external",
        .qa: "https://api.qabackit.com/account/login/external"
    ]
    
    var postBody: PostBody?

    init(postBody: PostBody) {
        self.postBody = postBody
    }
}
