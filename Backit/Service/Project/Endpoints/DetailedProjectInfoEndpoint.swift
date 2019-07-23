/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

struct DetailedProjectInfoEndpoint: ServiceEndpoint {
    
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
    struct ResponseType: Decodable {
        let projects: [ProjectsEndpoint.Project]
    }
    
    enum Header { }
    enum PathParameter: ServiceParameter {
        case projectId(Int)
    }
    enum QueryParameter { }
    enum PostBody { }
    
    var type: ServiceRequestType = .get
    var endpoints: Endpoints = [
        .qa: "https://api.qabackit.com/project/projects/{projectId}"
    ]
    var pathParameters: [PathParameter]?
    
    init(projectId: Int) {
        self.pathParameters = [
            .projectId(projectId)
        ]
    }
}
