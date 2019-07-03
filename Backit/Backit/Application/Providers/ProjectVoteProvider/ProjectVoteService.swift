/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

class ProjectVoteService: ProjectVoteProvider {    
    
    let queue: DispatchQueue
    let database: DatabaseProvider
    
    init(queue: DispatchQueue, database: DatabaseProvider) {
        self.queue = queue
        self.database = database
    }
    
    func votedFor(project: Project) -> Future<Bool, NoError> {
        let promise = Promise<Bool, NoError>()
        queue.async { [weak self] in
            guard let sself = self else {
                return promise.success(false)
            }
            let didVote = sself.database.didVoteForProject(project: project)
            promise.success(didVote)
        }
        return promise.future
    }
    
    func voteFor(project: Project) -> Future<IgnorableValue, ProjectVoteProviderError> {
        return Future(error: .generic(NotImplementedError()))
    }
}
