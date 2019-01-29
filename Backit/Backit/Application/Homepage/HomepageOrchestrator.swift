/**
 *
 * Copyright © 2018 Backit. All rights reserved.
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
    
    weak var client: HomepageClient?
    
    private enum QueryState {
        case notLoaded
        case loading
        case loaded(cursor: Any?)
    }
    private var queryState: QueryState = .notLoaded
    
    init(provider: ProjectProvider) {
        self.provider = provider
    }

    func viewDidLoad() {
        loadProjects()
    }
    
    func didTapAsset(project: HomepageProject) {
        
    }
    
    func didTapBackit(project: HomepageProject) {
        
    }
    
    func didTapComment(project: HomepageProject) {
        
    }
    
    func didReachEndOfProjectList() {
        loadProjects()
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
        }
        
        queryState = .loading
        provider.projects(offset: offset, limit: 10).onSuccess { [weak self] (response) in
            guard let self = self else {
                return
            }
            
            let homepageProjects = response.projects.map { (project) -> HomepageProject in
                return HomepageProject(project: project)
            }
            self.queryState = .loaded(cursor: response.cursor)
            self.client?.didReceiveProjects(homepageProjects)
        }
    }
}
