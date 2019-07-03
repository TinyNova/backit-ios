/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import BrightFutures

enum ProjectComment {
    case comments(Int)
    case comment
}

enum ProjectAsset {
    case image(URL)
    case video(previewURL: URL, videoURL: URL)
}

struct FeedProject {
    let context: Any
    let source: ProjectSource
    let assets: [ProjectAsset]
    let name: String
    let numberOfBackers: Int
    let comment: ProjectComment
    let numEarlyBirdRewards: Int
    let fundedPercent: Float
    let commentCount: Future<Int, Error>
    let voted: Future<Bool, NoError>
    let numDaysLeft: Int
    let numVotes: Int
}
