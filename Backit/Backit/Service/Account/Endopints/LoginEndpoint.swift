/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

struct LoginEndpoint: ServiceEndpoint {
    
    struct ResponseType: Decodable {
        /// Success Response
        let csrfToken: String?
        let refreshToken: String?
        // Ex: UUID
        let accountId: String?
        let token: String?
        
        /// Failure Response
        let message: String?
        // Ex: {"email": ["email is not valid"]}
        let validation: [String: [String]]?
    }

    enum Header { }
    enum PathParameter { }
    enum QueryParameter { }
    enum PostParameter {
        case email(String)
        case password(String)
    }
    typealias PostBody = [PostParameter]
    
    var type: ServiceRequestType = .post
    var httpBodyEncodingStrategy: HTTPBodyEncodingStrategy = .keyValue
    var endpoints: Endpoints = [
        .dev: "https://127.0.0.1/account/login",
        .qa: "https://api.qabackit.com/account/login"
    ]
    var postBody: PostBody?
    
    init(postBody: PostBody) {
        self.postBody = postBody
    }
}
