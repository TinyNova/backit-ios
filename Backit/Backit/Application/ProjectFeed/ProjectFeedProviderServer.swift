/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

class ProjectFeedProviderServer: ProjectFeedProvider {
    
    let projectProvider: ProjectProvider
    let discussionProvider: DiscussionProvider
    let metrics: AnalyticsPublisher<MetricAnalyticsEvent>
    
    weak var client: ProjectFeedClient?
    
    private enum QueryState {
        case notLoaded
        case loading
        case loaded(cursor: Any?)
        case noMoreResults
        case error(cursor: Any?)
    }
    private var queryState: QueryState = .notLoaded
    
    init(projectProvider: ProjectProvider, discussionProvider: DiscussionProvider, metrics: AnalyticsPublisher<MetricAnalyticsEvent>) {
        self.projectProvider = projectProvider
        self.discussionProvider = discussionProvider
        self.metrics = metrics
    }
    
    func loadProjects() {
        if case .error = queryState {
            _loadProjects()
        }
        else {
            startPageLoadTransaction()
            _loadProjects()
        }
    }
    
    // MARK: - HomepageProvider
    
    func didTapAsset(project: FeedProject) {
        
    }
    
    func didTapBackit(project: FeedProject) {
        
    }
    
    func didTapComment(project: FeedProject) {
        
    }
    
    func didReachEndOfProjectList() {
        _loadProjects()
    }
    
    // MARK: - Private
    
    private var pageNumber: Int = 0
    private func pageRequested() {
        pageNumber += 1
        metrics.send(.homepage(pageNumber: 1))
    }
    
    private func startPageLoadTransaction() {
        metrics.start(.appColdLaunch)
    }
    
    private func _loadProjects() {
        let offset: Any?
        switch queryState {
        case .error(let _offset):
            offset = _offset
        case .notLoaded:
            offset = nil
        case .loading:
            return
        case .loaded(let _offset):
            offset = _offset
        case .noMoreResults:
            return
        }
        
        pageRequested()
        
        queryState = .loading
        projectProvider.popularProjects(offset: offset, limit: 10)
            .onSuccess { [weak self] (response) in
                guard let sself = self else {
                    return
                }
                
                guard response.projects.count > 0 else {
                    sself.queryState = .noMoreResults
                    sself.client?.didReachEndOfProjects()
                    return
                }
                
                let future = sself.comments(for: response.projects)
                let projects = response.projects.map { (project) -> FeedProject in
                    return sself.feedProject(from: project, commentsFuture: future)
                }
                sself.queryState = .loaded(cursor: response.cursor)
                sself.client?.didReceiveProjects(projects)
            }
            .onFailure { [weak self] (error) in
                self?.queryState = .error(cursor: offset)
                self?.client?.didReceiveError(error)
            }
            .onComplete { [weak self] _ in
                self?.metrics.stop(.appColdLaunch)
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
        
        let future = commentsFuture.flatMap { (response) -> Future<Int, Error> in
            let count = response[project.id] ?? 0
            return Future<Int, Error>(value: count)
        }
        
        return FeedProject(
            context: project,
            source: project.source,
            assets: assets,
            name: project.name,
            numberOfBackers: project.numBackers,
            comment: .comment,
            numEarlyBirdRewards: project.numEarlyBirdRewards,
            fundedPercent: fundedPercent,
            commentCount: future,
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

