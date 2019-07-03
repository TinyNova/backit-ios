/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

class ProjectFeedService: ProjectFeedProvider {
    
    let projectProvider: ProjectProvider
    let projectComposition: ProjectFeedCompositionProvider
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
    
    init(projectProvider: ProjectProvider, projectComposition: ProjectFeedCompositionProvider,  metrics: AnalyticsPublisher<MetricAnalyticsEvent>) {
        self.projectProvider = projectProvider
        self.projectComposition = projectComposition
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
        let future = projectProvider.popularProjects(offset: offset, limit: 10)
        projectComposition.projects(from: future)
            .onSuccess { [weak self] (response) in
                guard response.projects.count > 0 else {
                    self?.queryState = .noMoreResults
                    self?.client?.didReachEndOfProjects()
                    return
                }

                self?.queryState = .loaded(cursor: response.cursor)
                self?.client?.didReceiveProjects(response.projects)
            }
            .onFailure { [weak self] (error) in
                self?.queryState = .error(cursor: offset)
                self?.client?.didReceiveError(error)
            }
            .onComplete { [weak self] _ in
                self?.metrics.stop(.appColdLaunch)
            }
    }
}

