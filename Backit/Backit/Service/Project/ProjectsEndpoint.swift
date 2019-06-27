/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

struct ProjectsEndpoint: ServiceEndpoint {
    
    /**
     Needed:
     - Comments (number of comments)
     - Video Preview URL
     - Video URL (can I use `video`?)
     - More project images?
     */
    
    /**
     Image extension info:
     p = portrait
     t = thumb
     c = card
     */
    struct ProjectImages: Decodable {
        let p: String
        let t: String
        let c: String
    }
    struct Project: Decodable {
        let projectId: String
        let site: String
        let externalId: String
        let url: String
        let internalUrl: String
        let slug: String
        let country: String
        let category: String
        let subCategory: String?
        let currency: String
        let name: String
        let goal: String
        let pledged: String
        let backerCount: String
        let blurb: String
        let image: ProjectImages
        let video: String?
        let visible: Bool
        let funding: Bool
        let hasEarlyBirdRewards: Bool
    }
    
    struct ResponseType: Decodable {
        let projects: [ProjectsEndpoint.Project]
    }
    
    enum Header { }
    enum PathParameter { }
    enum QueryParameter {
        case category(String)
        case subCategory(String)

        case country(String)
        case creatorId(String)
        case currency(String)
        case backerCountMin(Int)
        case backerCountMax(Int)
        case exclude([String])
        case funded(Bool)
        case funding(Bool)
        case fundStart(Date)
        case fundEnd(Date)
        case goalMin(Int)
        case goalMax(Int)
        case hasEarlyBirdRewards(Bool)
        case language(String)
        case pledgeMin(Int)
        case pledgeMax(Int)
        case query(String) // ?
        case site(String)
        case visible(Bool)

        case sort(String)
        case sortDirection(String)
        case offset(Int)
        case limit(Int)
    }
    enum PostBody { }
        
    var type: ServiceRequestType = .get
    var endpoints: Endpoints = [
        .qa: "https://collect.backit.com/projects"
    ]
    var queryParameters: [QueryParameter]?
    
    init(queryParameters: [QueryParameter]) {
        self.queryParameters = queryParameters
    }
}
