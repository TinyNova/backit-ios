/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

struct CreateExternalAccountEndpoint: ServiceEndpoint {
    
    struct ResponseType: Decodable {
        /// Success Response
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
    enum PostParameter {
        case userName(String)
        case signupToken(String)
        case email(String)
        case subscribe(Bool)
    }
    typealias PostBody = [PostParameter]
    
    var type: ServiceRequestType = .post
    var httpBodyEncodingStrategy: HTTPBodyEncodingStrategy = .keyValue
    var endpoints: Endpoints = [
        .dev: "https://127.0.0.1:8443/account/accounts/external",
        .qa: "https://api.qabackit.com/account/accounts/external"
    ]
    
    var postBody: PostBody?

    init(postBody: PostBody) {
        self.postBody = postBody
    }
}
