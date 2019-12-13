/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

struct CategoriesEndpoint: ServiceEndpoint {
    
    struct Category: Decodable {
        let categoryId: Int?
        let name: String?
    }
    struct Result: Decodable {
        let categories: [CategoriesEndpoint.Category]
    }
    
    typealias ResponseType = CategoriesEndpoint.Result
    
    enum Header { }
    enum PathParameter { }
    enum QueryParameter { }
    enum PostBody { }
    
    var type: ServiceRequestType = .get
    var endpoints: Endpoints = [
        .qa: "https://api.qabackit.com/project/categories"
    ]
}
