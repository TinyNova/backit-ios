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
    let externalUrl: URL?
    let internalUrl: URL?
    let name: String
    let goal: Int
    let pledged: Int
    let numBackers: Int
    let imageURLs: [URL]
    let videoPreviewURL: URL?
    let videoURL: URL?
    let numEarlyBirdRewards: Int
    let funded: Bool
    let numDaysLeft: Int
    let numVotes: Int
}
