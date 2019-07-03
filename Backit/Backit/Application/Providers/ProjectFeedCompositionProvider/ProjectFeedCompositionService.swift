/**
 * `ProjectFeed` composition service.
 *
 * Maps the following:
 * - A future used to return the number of comments for the project
 * - Whether the user has voted for the project
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

class ProjectFeedCompositionService: ProjectFeedCompositionProvider {
    
    let discussionProvider: DiscussionProvider
    let voteProvider: ProjectVoteProvider

    init(discussionProvider: DiscussionProvider, voteProvider: ProjectVoteProvider) {
        self.discussionProvider = discussionProvider
        self.voteProvider = voteProvider
    }
    
    func projects(from future: Future<ProjectResponse, ProjectProviderError>) -> Future<ProjectFeedResponse, ProjectProviderError> {
        return future
            .flatMap { [weak self] (response) -> Future<ProjectFeedResponse, ProjectProviderError> in
                guard let sself = self else {
                    return Future(error: .generic(WeakReferenceError()))
                }
                
                let future = sself.comments(for: response.projects)
                let projects = response.projects.map { (project) -> FeedProject in
                    return sself.feedProject(from: project, commentsFuture: future)
                }
                
                return Future(value: ProjectFeedResponse(cursor: response.cursor, projects: projects))
            }
    }
    
    private func feedProject(from project: Project, commentsFuture: Future<[ProjectId: Int], Error>) -> FeedProject {
        var assets: [ProjectAsset] = []
        assets.append(.image(project.imageURLs[0]))
        if let previewURL = project.videoPreviewURL, let videoURL = project.videoURL {
            assets.append(.video(previewURL: previewURL, videoURL: videoURL))
        }
        
        var fundedPercent = project.pledged > 0
            ? Float(project.pledged) / Float(project.goal)
            : 0
        // clamp to 100%
        fundedPercent = fundedPercent > 1 ? 1 : fundedPercent
        
        let countFuture = commentsFuture.flatMap { (response) -> Future<Int, Error> in
            let count = response[project.id] ?? 0
            return Future<Int, Error>(value: count)
        }
        let votedFuture = voteProvider.votedFor(project: project)
        
        return FeedProject(
            context: project,
            source: project.source,
            assets: assets,
            name: project.name,
            numberOfBackers: project.numBackers,
            comment: .comment,
            numEarlyBirdRewards: project.numEarlyBirdRewards,
            fundedPercent: fundedPercent,
            commentCount: countFuture,
            voted: votedFuture,
            numDaysLeft: project.numDaysLeft,
            numVotes: project.numVotes
        )
    }
    
    private func comments(for projects: [Project]) -> Future<[ProjectId: Int], Error> {
        return discussionProvider.commentCount(for: projects)
            .mapError { (error) -> Error in
                return error
        }
    }
    
    private func comments(for project: Project) -> Future<Int, Error> {
        return discussionProvider.commentCount(for: project)
            .mapError { (error) -> Error in
                return error
        }
    }
}
