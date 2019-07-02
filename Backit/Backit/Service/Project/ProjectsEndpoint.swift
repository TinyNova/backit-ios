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
    
    struct ProjectImages: Decodable {
        let project: String?
        let thumbnail: String?
        let card: String?
    }
    struct Creator: Decodable {
        let creatorId: Int?
        let name: String?
    }
    struct Project: Decodable {
        let projectId: Int?
        let site: String?
        let name: String?
        let blurb: String?
        let url: String? // URL to external site
        let internalUrl: String?
        let creator: Creator?
        let image: ProjectImages?
        let backerCount: Int?
        let country: String?
        let category: String?
        let language: String?
        let funding: Bool?
        let funded: Bool?
        let video: String?
        let visible: Bool?
        let votes: Int?
        let earlyBirdRewardCount: Int?
        let goal: Int?
        let pledged: Int?
        let fundStart: String?
        let fundEnd: String?
        let createdAt: String?
        let updatedAt: String?
    }
    struct Sort: Decodable {
        let relevance: String
    }
    struct ResponseType: Decodable {
//        let total: Int
//        let offset: Int
//        let limit: Int
//        let sort: Sort
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
        .qa: "https://api.qabackit.com/projects"
    ]
    var queryParameters: [QueryParameter]?
    
    init(queryParameters: [QueryParameter]) {
        self.queryParameters = queryParameters
    }
}
