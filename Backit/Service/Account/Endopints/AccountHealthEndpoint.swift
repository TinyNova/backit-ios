/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

struct AccountHealthEndpoint: ServiceEndpoint {
    
//    typealias ResponseType = Data
    struct ResponseType: Decodable {
        struct Build: Decodable {
            let commit: String?
            let branch: String?
            let pr: String?
            let built: String?
        }
        
        let env: String?
        let build: Build?
        let services: [String: Bool]?
    }
    
    enum Header { }
    enum PathParameter { }
    enum QueryParameter { }
    enum PostBody { }
    
    var type: ServiceRequestType = .get
    var endpoints: Endpoints = [
        .dev: "https://127.0.0.1:8443/account/health/verbose",
        .qa: "https://api.qabackit.com/account/health/verbose"
    ]
}
