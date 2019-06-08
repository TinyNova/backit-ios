/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

struct RecoverPasswordEndpoint: ServiceEndpoint {
    
    typealias ResponseType = Data
    
    enum Header { }
    enum PathParameter { }
    enum QueryParameter { }
    enum PostParameter {
        case email(String)
    }
    typealias PostBody = [PostParameter]
    
    var type: ServiceRequestType = .post
    var httpBodyEncodingStrategy: HTTPBodyEncodingStrategy = .keyValue
    var endpoints: Endpoints = [
        .qa: "https://api.qabackit.com/auth/recover"
    ]
    
    var postBody: PostBody?
    
    init(postBody: PostBody) {
        self.postBody = postBody
    }
}
