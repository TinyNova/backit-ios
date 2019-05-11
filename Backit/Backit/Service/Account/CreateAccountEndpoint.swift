/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

struct CreateAccountEndpoint: ServiceEndpoint {
    
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
    struct PostBody: Encodable {
        let email: String
        let userName: String
        let firstName: String?
        let lastName: String?
        let password: String
        let repeatPassword: String
        let subscribe: Bool
    }
    
    var type: ServiceRequestType = .post
    var httpBodyEncodingStrategy: HTTPBodyEncodingStrategy = .keyValue
    var endpoints: Endpoints = [
        .qa: "https://api.qabackit.com/account/accounts"
    ]
    
    var postBody: PostBody?
    
    init(postBody: PostBody) {
        self.postBody = postBody
    }
}
