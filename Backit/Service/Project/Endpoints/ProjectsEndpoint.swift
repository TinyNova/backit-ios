/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

struct ProjectsEndpoint: ServiceEndpoint {
    
    /**
     TODO:
     - Video URL (Is `video` what should be used for the preview?)
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
    struct Video: Decodable {
        struct Platform: Decodable {
            let desktop: URL?
            let mobile: URL?
        }
        struct Transcription: Decodable {
            let origina: URL?
            let srt: URL?
            let vtt: URL?
        }
        let url: URL? // If this value exists, do nothing.
        let standard: Platform?
        let original: URL?
        let streaming: Platform?
        let transcriptions: Transcription
        let audio: URL?
        let source: URL?
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
        let video: Video?
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
    struct Response: Decodable {
//        let total: Int
//        let offset: Int
//        let limit: Int
//        let sort: Sort
        let projects: [ProjectsEndpoint.Project]
    }
    typealias ResponseType = Response
    
    enum Header { }
    enum PathParameter { }
    enum QueryParameter: ServiceParameter {
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
        .qa: "https://api.qabackit.com/project/projects"
    ]
    var queryParameters: [QueryParameter]?
    
    init(queryParameters: [QueryParameter]) {
        self.queryParameters = queryParameters
    }
}
