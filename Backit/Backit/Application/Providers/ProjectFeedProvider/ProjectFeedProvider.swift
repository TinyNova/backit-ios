/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

protocol ProjectFeedClient: class {
    func didReceiveProjects(_ projects: [FeedProject])
    func didReachEndOfProjects()
    func didReceiveError(_ error: Error)
}

protocol ProjectFeedProvider {
    var client: ProjectFeedClient? { get set }
    
    func loadProjects()
    func didTapAsset(project: FeedProject)
    func didTapBackit(project: FeedProject)
    func didTapComment(project: FeedProject)
    func didReachEndOfProjectList()
}
