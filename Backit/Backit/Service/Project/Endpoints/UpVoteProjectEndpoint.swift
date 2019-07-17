/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

struct UpVoteProjectEndpoint: ServiceEndpoint {

    typealias ResponseType = Data

    enum Header { }
    enum PathParameter { }
    enum QueryParameter { }
    enum PostParameter: ServiceParameter {
        case projectId(Int)
        case vote(String) // `up` or `down`
    }
    typealias PostBody = [PostParameter]

    var type: ServiceRequestType = .post
    var httpBodyEncodingStrategy: HTTPBodyEncodingStrategy = .keyValue
    var endpoints: Endpoints = [
        .qa: "https://api.qabackit.com/project/account/votes"
    ]
    var plugins: [ServicePluginKey]? = [
        .authorization
    ]
    
    var postBody: PostBody?

    init(postBody: PostBody) {
        self.postBody = postBody
    }
}
