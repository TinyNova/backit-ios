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

struct FeedProject {
    let context: Any
    let source: ProjectSource
    let assets: [ProjectAsset]
    let name: String
    let numberOfBackers: Int
    let comment: ProjectComment
    let isEarlyBird: Bool
    let fundedPercent: Float
    
    static func make(from project: Project) -> FeedProject {
        var assets: [ProjectAsset] = []
        assets.append(.image(project.imageURLs[0]))
        if let previewURL = project.videoPreviewURL, let videoURL = project.videoURL {
            assets.append(.video(previewURL: previewURL, videoURL: videoURL))
        }
        
        let fundedPercent = project.pledged > 0
            ? Float(project.pledged) / Float(project.goal)
            : 0
        
        return FeedProject(
            context: 1,
            source: project.source,
            assets: assets,
            name: project.name,
            numberOfBackers: project.numBackers,
            comment: .comment,
            isEarlyBird: project.hasEarlyBirdRewards,
            fundedPercent: fundedPercent
        )
    }
}
