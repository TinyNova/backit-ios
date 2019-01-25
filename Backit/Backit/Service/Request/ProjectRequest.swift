/**
 *
 * Copyright © 2018 Backit. All rights reserved.
 */

import Foundation

struct ProjectRequest: Request {
    
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
        let projects: [ProjectRequest.Project]
    }
    
    enum Header {
        
    }
    enum GetParameter {
        case funding(Bool)
        case backerCountMin(Int)
        case country(String)
        case sort(String)
        case sortDirection(String)
        case offset(Int)
        case limit(Int)
    }
    enum PostParameter {
        
    }
    
    static var environment: Environment = .prod
    
    var type: RequestType = .get
    var url = "https://collect.backit.com/projects"
    var headers: [Header]? = nil
    var getParameters: [GetParameter]?
    var postParameters: [PostParameter]? = nil
    
    init(getParameters: [GetParameter]) {
        self.getParameters = getParameters
    }
}
