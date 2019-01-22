/**
 *
 * Copyright © 2018 Backit. All rights reserved.
 */

import BrightFutures
import Foundation

class ProjectService: ProjectProvider {
    
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
    private var projects: [Project] = [
        Project(
            id: 1,
            source: .kickstarter,
            url: URL(string: "https://cdn.collect.backit.com/pictures/2/f/c/a/e/2fcae53923676aea72f9eeb7fae822e0t.jpg")!,
            name: "",
            goal: 0,
            pledged: 0,
            numBackers: 0,
            imageURLs: [URL(string: "https://cdn.collect.backit.com/pictures/2/f/c/a/e/2fcae53923676aea72f9eeb7fae822e0t.jpg")!],
            videoPreviewURL: nil,
            videoURL: nil,
            hasEarlyBirdRewards: true,
            funded: true
        )
    ]

    func allProjects() -> Future<[Project], ProjectProviderError> {
        return Future(value: projects)
    }
}
