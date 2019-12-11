/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

struct ProjectSearchEndpoint: ServiceEndpoint {
    
    struct VideoPlatform: Decodable {
        let desktop: String
        let mobile: String
    }
    struct VideoTranscriptions: Decodable {
        let original: String
        let srt: String
        let vtt: String
    }
    struct Videos: Decodable {
        let standard: VideoPlatform?
        let streaming: VideoPlatform?
        let original: String?
        let transcriptions: VideoTranscriptions?
        let audio: String?
        let source: String?
    }
    struct Images: Decodable {
        let thumbnail: String?
        let project: String?
        let card: String?
    }
    struct Project: Decodable {
        let projectId: Int
        let site: String?
        let name: String?
        let image: ProjectSearchEndpoint.Images
        let funding: Bool
        let goal: Int?
        let visible: Bool
        let pledged: Int?
        let funded: Bool?
        let fundStart: String
        let fundEnd: String
        let earlyBirdRewardCount: Int?
        let language: String
        let video: Videos?
        let blurb: String
        let backerCount: Int?
        let url: String
        let votes: Int?
        let category: String?
    }
    struct Sort: Decodable {
        let key: String
        let direction: String
    }
    struct Result: Decodable {
        let total: Int
        let projects: [ProjectSearchEndpoint.Project]
        let offset: Int
        let limit: Int
        let sort: Sort
    }
    
    typealias ResponseType = ProjectSearchEndpoint.Result
    
    enum Header { }
    enum PathParameter { }
    enum QueryParameter: ServiceParameter {
        case query(String)
        case site(String) // ?
        case category(String) // ?
        case country(String) // ?
        case currency(String) // ?
        case funding(Bool)
        case hasEarlyBirdRewards(Bool)
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
    var queryParameters: [ProjectSearchEndpoint.QueryParameter]?
    
    init(_ queryParameters: [QueryParameter]) {
        self.queryParameters = queryParameters
    }
}
