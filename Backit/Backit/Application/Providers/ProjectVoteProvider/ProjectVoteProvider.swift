/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

enum ProjectVoteProviderError: Error {
    case generic(Error)
    case noUser
}

protocol ProjectVoteProvider {
    func votedFor(project: Project) -> Future<Bool, NoError>
    func voteFor(project: Project) -> Future<IgnorableValue, ProjectVoteProviderError>
}
