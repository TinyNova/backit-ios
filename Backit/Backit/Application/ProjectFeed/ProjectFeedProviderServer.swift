/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

class ProjectFeedProviderServer: ProjectFeedProvider {
    
    let provider: ProjectProvider
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
    
    init(provider: ProjectProvider, metrics: AnalyticsPublisher<MetricAnalyticsEvent>) {
        self.provider = provider
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
        provider.projects(offset: offset, limit: 10)
            .onSuccess { [weak self] (response) in
                guard let self = self else {
                    return
                }
                
                guard response.projects.count > 0 else {
                    self.queryState = .noMoreResults
                    self.client?.didReachEndOfProjects()
                    return
                }
                
                let homepageProjects = response.projects.map { (project) -> FeedProject in
                    return FeedProject.make(from: project)
                }
                self.queryState = .loaded(cursor: response.cursor)
                self.client?.didReceiveProjects(homepageProjects)
            }
            .onFailure { [weak self] (error) in
                self?.queryState = .error(cursor: offset)
                self?.client?.didReceiveError(error)
            }
            .onComplete { _ in
                self.metrics.stop(.appColdLaunch)
        }
    }
}
