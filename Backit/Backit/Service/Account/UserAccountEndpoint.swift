/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

struct UserAccountEndpoint: ServiceEndpoint {
    
    struct ResponseType: Decodable {
    }
    
    enum Header { }
    enum PathParameter { }
    enum QueryParameter { }
    enum PostParameter { }
    
    var type: ServiceRequestType = .get
    var endpoints: Endpoints = [
        .qa: "https://api.qabackit.com/account/accounts/me"
    ]
    var plugins: [ServicePluginKey]? = [
        .authorization
    ]
}
