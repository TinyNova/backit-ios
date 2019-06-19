/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

struct UserAccountEndpoint: ServiceEndpoint {
    
//    enum AccountType: String, Decodable {
//        case USER
//    }

    // NOTE: To see the raw response data, set the `ResponseType` to `Data`
//    typealias ResponseType = Data
    struct ResponseType: Decodable {
        // NOTE: Provided when an error occurs
        let message: String?
        
        // Success response
//        let location: String?
        let accountId: String
        let userName: String
        let firstName: String?
        let lastName: String?
        let avatar: URL?
        let active: Bool
//        let accountType: AccountType?
//        let updatedAt: Date?
//        let createdAt: Date? // Ex: 2019-05-01T18:39:49.744Z
        let subscribe: Bool
    }
    
    enum Header { }
    enum PathParameter { }
    enum QueryParameter { }
    enum PostBody { }
    
    var type: ServiceRequestType = .get
    var endpoints: Endpoints = [
        .qa: "https://api.qabackit.com/account/accounts/me"
    ]
    var plugins: [ServicePluginKey]? = [
        .authorization
    ]
}
