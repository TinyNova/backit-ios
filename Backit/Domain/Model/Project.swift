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

struct Author {
    let name: String
    let avatarUrl: URL?
}
struct Reward {
    let name: String
    let cost: String
    let numberOfBackers: Int
    let total: Int
}
struct DetailedProject {
    let id: ProjectId
    let source: ProjectSource
    let externalUrl: URL?
    let internalUrl: URL?
    let name: String
    let goal: Int
    let pledged: Int
    let numBackers: Int
    let author: Author
    let category: String
    let country: String
    let blurb: String
    let text: String
    let rewards: [Reward]
    let imageUrl: URL?
    let videoUrl: URL?
}
