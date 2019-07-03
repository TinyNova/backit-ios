/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

struct ProjectFeedResponse {
    let cursor: Any?
    let projects: [FeedProject]
}

protocol ProjectFeedCompositionProvider {
    func projects(from future: Future<ProjectResponse, ProjectProviderError>) -> Future<ProjectFeedResponse, ProjectProviderError>
}
