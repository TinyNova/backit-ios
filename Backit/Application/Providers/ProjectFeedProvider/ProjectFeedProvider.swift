/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

protocol ProjectFeedClient: class {
    func didReceiveProjects(_ projects: [FeedProject], reset: Bool)
    func didReachEndOfProjects()
    func didReceiveError(_ error: Error)
}

protocol ProjectFeedProvider {
    var client: ProjectFeedClient? { get set }
    
    func loadProjects()
    func reloadProjects()
    func didReachEndOfProjectList()
    func didVoteFor(project: FeedProject, action: VoteAction)
}
