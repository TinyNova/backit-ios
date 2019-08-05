/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

class ProjectVoteService: ProjectVoteProvider {    

    let database: DatabaseProvider
    let projectProvider: ProjectProvider
    
    init(database: DatabaseProvider, projectProvider: ProjectProvider, userStream: UserStreamer) {
        self.database = database
        self.projectProvider = projectProvider
        userStream.listen(self)
    }
    
    func votedFor(project: Project) -> Future<Bool, NoError> {
        return Future(value: database.didVoteForProject(project))
    }
    
    func voteFor(project: Project) -> Future<IgnorableValue, NoError> {
        return projectProvider.upVote(project: project)
            .onSuccess { [weak self] _ in
                self?.database.voteForProject(project)
            }
            .mapError { (error) -> NoError in
                // TODO: Re-upload in the event of a failure?
                return NoError()
            }
    }
    
    func removeVoteFor(project: Project) -> Future<IgnorableValue, NoError> {
        return projectProvider.removeVote(from: project)
            .onSuccess { [weak self] _ in
                self?.database.removeVoteFromProject(project)
            }
            .mapError { (error) -> NoError in
                // TODO: Re-upload in the event of a failure?
                return NoError()
            }
    }

    // MARK: - Private methods

    private func synchronizeVotes() {
        // TODO: Synchronize votes from server and update database
        // Alternatively, synchronization could happen when the first vote is requested
    }
}

extension ProjectVoteService: UserStreamListener {
    func didChangeUser(_ user: User) {
        database.load(for: user)
        synchronizeVotes()
    }
}
