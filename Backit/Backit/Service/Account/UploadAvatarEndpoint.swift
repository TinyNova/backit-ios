/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

struct UploadAvatarEndpoint: ServiceEndpoint {
    
    // NOTE: To see the raw response data, set the `ResponseType` to `Data`
//    typealias ResponseType = Data
    struct ResponseType: Decodable {
        let bucket: String?
        let acl: String?
        let awsKey: String?
        let key: String?
        let policy: String?
        let signature: String?

        let error: String?
    }
    
    enum Header { }
    enum PathParameter { }
    enum QueryParameter { }
    enum PostBody { }
    
    var type: ServiceRequestType = .get
    var endpoints: Endpoints = [
        .qa: "https://api.qabackit.com/account/accounts/upload/avatar-url"
    ]
    var plugins: [ServicePluginKey]? = [
        .authorization
    ]
}
