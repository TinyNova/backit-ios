/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

struct UsernameAvailabilityEndpoint: ServiceEndpoint {
    
    struct ResponseType: Decodable {
        let found: Bool
    }
    
    enum Header { }
    enum PathParameter {
        case userName(String)
    }
    enum QueryParameter { }
    enum PostBody { }
    
    var type: ServiceRequestType = .get
    var httpBodyEncodingStrategy: HTTPBodyEncodingStrategy = .keyValue
    var endpoints: Endpoints = [
        .qa: "https://api.qabackit.com/account/accounts/{userName}/available"
    ]
    
    var pathParameters: [PathParameter]?
    
    init(pathParameters: [PathParameter]) {
        self.pathParameters = pathParameters
    }
}
