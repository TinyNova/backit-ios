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
        let avatar: URL?
        let siteId: Int?
        let externalId: String?
        let createdAt: String?
        let updatedAt: String?
    }
    struct Reward: Decodable {
        let amount: Int?
        let description: String?
        let numberAvailable: Int?
    }
    struct Currency: Decodable {
        let currencyId: Int?
        let name: String?
    }
    struct Country: Decodable {
        let countryId: Int?
        let name: String?
        let twoDigitCode: String?
        let threeDigitCode: String?
    }
    struct Site: Decodable {
        let siteId: Int?
        let name: String?
    }
    struct Category: Decodable {
        let categoryId: Int?
        let name: String?
    }
    struct Language: Decodable {
        let languageId: Int?
        let name: String?
    }
    struct Project: Decodable {
        let projectId: Int?
        let site: Site?
        let name: String?
        let blurb: String?
        let url: URL? // URL to external site
        let internalUrl: URL?
        let creator: Creator?
        let image: ProjectImages?
        let backerCount: Int?
        let country: Country?
        let category: Category?
        let language: Language?
        let funding: Bool?
        let funded: Bool?
        let video: String?
        let visible: Bool?
        let votes: Int?
        let voteCount: Int?
        let earlyBirdRewardCount: Int?
        let goal: Int?
        let pledged: Int?
        let fundStart: String?
        let fundEnd: String?
        let createdAt: String?
        let updatedAt: String?
        let projectText: String?
        let rewards: [DetailedProjectInfoEndpoint.Reward]?
        let currency: Currency?
    }
    typealias ResponseType = DetailedProjectInfoEndpoint.Project
    
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
