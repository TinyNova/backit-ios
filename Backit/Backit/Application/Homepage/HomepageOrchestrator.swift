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
                var assets: [ProjectAsset] = []
                assets.append(.image(project.imageURLs[0]))
                if let previewURL = project.videoPreviewURL, let videoURL = project.videoURL {
                    assets.append(.video(previewURL: previewURL, videoURL: videoURL))
                }
                
                let fundedPercent = project.pledged > 0
                                  ? Float(project.pledged) / Float(project.goal)
                                  : 0
                
                return HomepageProject(
                    context: 1,
                    source: project.source,
                    assets: assets,
                    name: project.name,
                    numberOfBackers: project.numBackers,
                    comment: .comment,
                    isEarlyBird: project.hasEarlyBirdRewards,
                    fundedPercent: fundedPercent
                )
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
