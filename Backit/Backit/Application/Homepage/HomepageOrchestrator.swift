/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

enum ProjectProviderError: Error {
    case failedToLoadProject
}

protocol ProjectProvider {
    func projects(offset: Any?, limit: Int) -> Future<ProjectResponse, ProjectProviderError>
}

class HomepageOrchestrator: HomepageProvider {
    
    let provider: ProjectProvider
    let metrics: AnalyticsPublisher<MetricAnalyticsEvent>
    
    weak var client: HomepageClient?
    
    private enum QueryState {
        case notLoaded
        case loading
        case loaded(cursor: Any?)
        case noMoreResults
    }
    private var queryState: QueryState = .notLoaded
    
    init(provider: ProjectProvider, metrics: AnalyticsPublisher<MetricAnalyticsEvent>) {
        self.provider = provider
        self.metrics = metrics
    }

    func viewDidLoad() {
        startPageLoadTransaction()
        loadProjects()
    }
    
    // MARK: - HomepageProvider
    
    func didTapAsset(project: HomepageProject) {
        
    }
    
    func didTapBackit(project: HomepageProject) {
        
    }
    
    func didTapComment(project: HomepageProject) {
        
    }
    
    func didReachEndOfProjectList() {
        loadProjects()
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

    private func loadProjects() {
        let offset: Any?
        switch queryState {
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
        provider.projects(offset: offset, limit: 10).onSuccess { [weak self] (response) in
            guard let self = self else {
                return
            }
            
            guard response.projects.count > 0 else {
                self.queryState = .noMoreResults
                self.client?.didReachEndOfProjects()
                return
            }
            
            let homepageProjects = response.projects.map { (project) -> HomepageProject in
                return HomepageProject(project: project)
            }
            self.queryState = .loaded(cursor: response.cursor)
            self.client?.didReceiveProjects(homepageProjects)
            self.metrics.stop(.appColdLaunch)
        }
    }
}
