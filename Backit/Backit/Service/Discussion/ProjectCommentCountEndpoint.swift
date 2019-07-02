/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

struct ProjectCommentCountEndpoint: ServiceEndpoint {    
    
    struct Error: Decodable {
        let message: String?
        let validation: [String: [String]]?
    }
    
    typealias ResponseType = TopLevelServiceResponse<Int, ProjectCommentCountEndpoint.Error>

    var decoder: ((Data?) -> ResponseType)? = { (data: Data?) -> ResponseType in
        return TopLevelServiceResponse(from: data).fallback(0)
    }
    
    enum Header { }
    enum PathParameter {
        case projectId(String)
    }
    enum QueryParameter { }
    enum PostBody { }
    
    var type: ServiceRequestType = .get
    var endpoints: Endpoints = [
        .dev: "https://127.0.0.1:8443/hub/comments/{projectId}/count",
        .qa: "https://api.qabackit.com/hub/comments/{projectId}/count"
    ]
    var plugins: [ServicePluginKey]? = [
        .authorization
    ]
    
    var pathParameters: [PathParameter]?
    
    init(projectId: ProjectId) {
        self.pathParameters = [.projectId(String(projectId))]
    }
}
