/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

struct ExternalLoginEndpoint: ServiceEndpoint {
        
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
        case accessToken(String)
        /// `provider` options are: `facebook`, `google`
        case provider(String)
    }
    typealias PostBody = [PostParameter]

    var type: ServiceRequestType = .post
    var httpBodyEncodingStrategy: HTTPBodyEncodingStrategy = .keyValue
    var endpoints: Endpoints = [
        .qa: "https://api.qabackit.com/account/login/external"
    ]
}
