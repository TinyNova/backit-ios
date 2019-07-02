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
                
                let projects = response.projects.map { (project) -> FeedProject in
                    return sself.feedProject(from: project)
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
    
    private func feedProject(from project: Project) -> FeedProject {
        var assets: [ProjectAsset] = []
        assets.append(.image(project.imageURLs[0]))
        if let previewURL = project.videoPreviewURL, let videoURL = project.videoURL {
            assets.append(.video(previewURL: previewURL, videoURL: videoURL))
        }
        
        let fundedPercent = project.pledged > 0
            ? Float(project.pledged) / Float(project.goal)
            : 0
        
        return FeedProject(
            context: project,
            source: project.source,
            assets: assets,
            name: project.name,
            numberOfBackers: project.numBackers,
            comment: .comment,
            isEarlyBird: project.hasEarlyBirdRewards,
            fundedPercent: fundedPercent,
            commentCount: comments(for: project)
        )
    }
    
    private func comments(for project: Project) -> Future<Int, Error> {
        return discussionProvider.commentCount(for: project)
            .mapError { (error) -> Error in
                return error
            }
    }
}

