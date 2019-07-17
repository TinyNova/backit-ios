/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

struct RemoveVoteEndpoint: ServiceEndpoint {
    
    typealias ResponseType = Data
    
    enum Header { }
    enum PathParameter: ServiceParameter {
        case projectId(Int)
    }
    enum QueryParameter { }
    enum PostBody { }
    
    var type: ServiceRequestType = .delete
    var httpBodyEncodingStrategy: HTTPBodyEncodingStrategy = .keyValue
    var endpoints: Endpoints = [
        .qa: "https://api.qabackit.com/project/account/votes/{projectId}"
    ]
    var plugins: [ServicePluginKey]? = [
        .authorization
    ]
    
    var pathParameters: [PathParameter]?
    
    init(pathParameters: [PathParameter]) {
        self.pathParameters = pathParameters
    }
}
