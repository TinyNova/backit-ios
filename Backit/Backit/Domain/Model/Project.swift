/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

typealias ProjectId = Int

struct ProjectResponse {
    let cursor: Any?
    let projects: [Project]
}

struct Project {
    let id: ProjectId
    let source: ProjectSource
    let slug: String
    let url: URL? // External URL
    let name: String
    let goal: Int
    let pledged: Int
    let numBackers: Int
    let imageURLs: [URL]
    let videoPreviewURL: URL?
    let videoURL: URL?
    let hasEarlyBirdRewards: Bool
    let funded: Bool
    
    var backitUrl: URL? {
        return URL(string: "https://backit.com/project/\(id)/\(slug)")
    }
}
