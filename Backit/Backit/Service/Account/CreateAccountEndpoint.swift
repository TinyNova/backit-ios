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
    enum PostParameter {
        case email(String)
        case userName(String)
        case firstName(String) // Optional
        case lastName(String) // Optional
        case password(String)
        case repeatPassword(String)
        case subscribe(Bool)
    }
    
    var type: ServiceRequestType = .post
    var httpBodyEncodingStrategy: HTTPBodyEncodingStrategy = .keyValue
    var endpoints: Endpoints = [
        .qa: "https://api.qabackit.com/account/accounts"
    ]
    
    var postParameters: [CreateAccountEndpoint.PostParameter]?
    
    init(postParameters: [PostParameter]) {
        self.postParameters = postParameters
    }
}
