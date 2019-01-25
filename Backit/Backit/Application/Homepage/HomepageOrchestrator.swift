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
    func projects(offset: Any?) -> Future<ProjectResponse, ProjectProviderError>
}

class HomepageOrchestrator: HomepageProvider {
    
    let provider: ProjectProvider
    
    weak var client: HomepageClient?
    
    init(provider: ProjectProvider) {
        self.provider = provider
    }

    func viewDidLoad() {
        provider.projects(offset: nil).onSuccess { [weak client] (response) in
            let homepageProjects = response.projects.map { (project) -> HomepageProject in                
                return HomepageProject(project: project)
            }
            client?.didReceiveProjects(homepageProjects)
        }
    }
    
    func didTapAsset(project: HomepageProject) {
        
    }
    
    func didTapBackit(project: HomepageProject) {
        
    }
    
    func didTapComment(project: HomepageProject) {
        
    }
}
