/**
 *
 * Copyright © 2018 Backit. All rights reserved.
 */

import BrightFutures
import Foundation

class ProjectService: Service, ProjectProvider {
    
    struct ProjectRequest: Request {
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
            let video: String
            let visible: Bool
            let funding: Bool
            let hasEarlyBirdRewards: Bool
        }
        
        struct ResponseType: Decodable {
            let projects: [ProjectRequest.Project]
        }
        
        enum Parameter {
            case funding(Bool)
            case backerCountMin(Int)
            case country(String)
            case sort(String)
            case sortDirection(String)
            case offset(Int)
            case limit(Int)
        }
        
        var url = "https://collect.backit.com/projects"
        var parameters: [Parameter]
        
        init(parameters: [Parameter]) {
            self.parameters = parameters
        }
    }
    
    /**
     Needed:
     - Comments (number of comments)
     - Video Preview URL
     - Video URL (can I use `video`?)
     - More project images?
     
     Image extension info:
     p = portrait
     t = thumb
     c = card
     */
//    private var projects: [Project] = [
//        Project(
//            id: 1,
//            source: .kickstarter,
//            url: URL(string: "https://cdn.collect.backit.com/pictures/2/f/c/a/e/2fcae53923676aea72f9eeb7fae822e0t.jpg")!,
//            name: "A very long name for a product",
//            goal: 0,
//            pledged: 0,
//            numBackers: 0,
//            imageURLs: [URL(string: "https://cdn.collect.backit.com/pictures/2/f/c/a/e/2fcae53923676aea72f9eeb7fae822e0t.jpg")!],
//            videoPreviewURL: nil,
//            videoURL: nil,
//            hasEarlyBirdRewards: true,
//            funded: true
//        )
//    ]
    
    func projects(offset: Any?) -> Future<ProjectResponse, ProjectProviderError> {
        let nextOffset: Int
        if let offset = offset as? Int {
            nextOffset = offset + 10
        }
        else {
            nextOffset = 0
        }
        
        let request = ProjectRequest(parameters: [
            .funding(true),
            .backerCountMin(100),
            .country("United States"),
            .sort("backerCount"),
            .sortDirection("desc"),
            .offset(nextOffset),
            .limit(10)
        ])
        return self.request(request)
            .map { response -> ProjectResponse in
                return ProjectResponse(from: response, offset: nextOffset)
            }
            .mapError { error -> ProjectProviderError in
                return .failedToLoadProject
            }
    }
}
