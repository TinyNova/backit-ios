/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

struct ProjectCommentCountsEndpoint: ServiceEndpoint {
    
    struct ResponseType: Decodable {
        let projects: [Int: Int]?
        
        /// Failure Response
        let message: String?
        let validation: [String: [String]]?
    }
    
    enum Header { }
    enum PathParameter { }
    enum QueryParameter {
        /// List of ProjectIDs separated by a comma
        case projectIds(String)
    }
    enum PostBody { }
    
    var type: ServiceRequestType = .get
    var endpoints: Endpoints = [
        .dev: "https://127.0.0.1:8443/hub/comments/count",
        .qa: "https://api.qabackit.com/hub/comments/count"
    ]
    
    var queryParameters: [ProjectCommentCountsEndpoint.QueryParameter]?
    
    init(projectIds: [ProjectId]) {
        self.queryParameters = [.projectIds(projectIds.compactMap { String($0) }.joined(separator: ","))]
    }
}
