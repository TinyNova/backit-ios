/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

struct RefreshTokenEndpoint: ServiceEndpoint {
    
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
        case accountId(String)
        case refreshToken(String)
    }
    typealias PostBody = [PostParameter]
    
    var type: ServiceRequestType = .post
    var httpBodyEncodingStrategy: HTTPBodyEncodingStrategy = .keyValue
    var endpoints: Endpoints = [
        .qa: "https://api.qabackit.com/account/login/refresh"
    ]
    
    var postBody: PostBody?
    
    init(postBody: PostBody) {
        self.postBody = postBody
    }
}
