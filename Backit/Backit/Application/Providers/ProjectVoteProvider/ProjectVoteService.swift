/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

class ProjectVoteService: ProjectVoteProvider {
    func votedFor(project: Project) -> Future<Bool, Error> {
        return Future(value: false)
    }
    
    func voteFor(project: Project) -> Future<IgnorableValue, Error> {
        return Future(error: NotImplementedError())
    }
}
