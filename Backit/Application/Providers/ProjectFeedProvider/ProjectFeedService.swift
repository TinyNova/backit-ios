/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

import BKFoundation

class ProjectFeedService: ProjectFeedProvider {
    
    private let projectProvider: ProjectProvider
    private let projectComposition: ProjectFeedCompositionProvider
    private let metrics: AnalyticsPublisher<MetricAnalyticsEvent>
    private let voteProvider: ProjectVoteProvider

    weak var client: ProjectFeedClient?
    
    private var user: User?
    
    private enum QueryState {
        case notLoaded
        case loading
        case loaded(cursor: Any?)
        case noMoreResults
        case error(cursor: Any?)
    }
    private var queryState: QueryState = .notLoaded
    
    init(projectProvider: ProjectProvider, projectComposition: ProjectFeedCompositionProvider,  metrics: AnalyticsPublisher<MetricAnalyticsEvent>, userStream: UserStreamer, voteProvider: ProjectVoteProvider) {
        self.projectProvider = projectProvider
        self.projectComposition = projectComposition
        self.metrics = metrics
        self.voteProvider = voteProvider
        
        // TODO: Do not send a request until the app has finished loading
        userStream.listen(self)
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
    
    func reloadProjects() {
        queryState = .notLoaded
        loadProjects()
    }
    
    // MARK: - HomepageProvider

    var isPerformingAction: Bool = false
    func didVoteFor(project: FeedProject, action: VoteAction) {
        guard let project = project.context as? Project else {
            return log.w("Failed to cast `FeedProject.context` to `Project`")
        }
        
        isPerformingAction = true
        switch action {
        case .add:
            voteProvider.voteFor(project: project).onComplete { [weak self] _ in
                self?.isPerformingAction = false
            }
        case .remove:
            voteProvider.removeVoteFor(project: project).onComplete { [weak self] _ in
                self?.isPerformingAction = false
            }
        }
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
        guard user != nil else {
            return
        }
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
        
        // TODO: Determine which query to use depending on the user status
        let future = projectProvider.popularProjects(offset: offset, limit: 10)
        projectComposition.projects(from: future)
            .onSuccess { [weak self] (response) in
                guard response.projects.count > 0 else {
                    self?.queryState = .noMoreResults
                    self?.client?.didReachEndOfProjects()
                    return
                }

                self?.queryState = .loaded(cursor: response.cursor)
                self?.client?.didReceiveProjects(response.projects, reset: offset == nil)
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

extension ProjectFeedService: UserStreamListener {
    func didChangeUser(_ user: User) {
        // The user hasn't changed. Do not reload projects.
        guard self.user != user else {
            return
        }
        
        self.user = user

        // Do not reload projects if we are currently performing an action on the page. This means the content on the page is relevant to the user.
        if isPerformingAction {
            return
        }
        
        reloadProjects()
    }
}
