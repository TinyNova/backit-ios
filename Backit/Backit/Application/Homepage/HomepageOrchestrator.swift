/**
 *
 * Copyright © 2018 Backit. All rights reserved.
 */

import BrightFutures
import Foundation

struct Project {
    let id: Any
    let source: ProjectSource
    let url: URL? // Internal Backit URL
    let name: String
    let goal: Int
    let pledged: Int
    let numBackers: Int
    let imageURLs: [URL]
    let videoPreviewURL: URL?
    let videoURL: URL?
    let hasEarlyBirdRewards: Bool
    let funded: Bool
}

enum ProjectProviderError: Error {
    case failedToLoadProject
}

protocol ProjectProvider {
    func allProjects() -> Future<[Project], ProjectProviderError>
}

class HomepageOrchestrator: HomepageProvider {
    
    let provider: ProjectProvider
    
    weak var client: HomepageClient?
    
    init(provider: ProjectProvider) {
        self.provider = provider
    }

    func viewDidLoad() {
        provider.allProjects().onSuccess { [weak client] (projects) in
            let homepageProjects = projects.map { (project) -> HomepageProject in
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
                    source: .kickstarter,
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
