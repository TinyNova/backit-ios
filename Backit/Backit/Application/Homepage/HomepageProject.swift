/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

enum ProjectComment {
    case comments(Int)
    case comment
}

enum ProjectAsset {
    case image(URL)
    case video(previewURL: URL, videoURL: URL)
}

struct HomepageProject {
    let context: Any
    let source: ProjectSource
    let assets: [ProjectAsset]
    let name: String
    let numberOfBackers: Int
    let comment: ProjectComment
    let isEarlyBird: Bool
    let fundedPercent: Float
}
