/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

class DiscussionService: DiscussionProvider {
    
    let service: Service
    
    init(service: Service) {
        self.service = service
    }
    
    func commentCount(for project: Project) -> Future<ProjectId, DiscussionProviderError> {
        let endpoint = ProjectCommentCountEndpoint(projectId: project.id)
        return service.request(endpoint)
            .mapError { (error) -> DiscussionProviderError in
                return .generic(error)
            }
            .flatMap { (response) -> Future<Int, DiscussionProviderError> in
                if let alternate = response.alternate {
                    return Future(error: .server(message: alternate.message, metadata: alternate.validation))
                }
                return Future(value: response.value ?? 0)
            }
    }
    
    func commentCount(for projects: [Project]) -> Future<[ProjectId : Int], DiscussionProviderError> {
        let projectIds = projects.map { (project) -> ProjectId in
            return project.id
        }
        let endpoint = ProjectCommentCountsEndpoint(projectIds: projectIds)
        return service.request(endpoint)
            .mapError { (error) -> DiscussionProviderError in
                return .generic(error)
            }
            .flatMap { (response) -> Future<[ProjectId: Int], DiscussionProviderError> in
                return Future(value: response.projects ?? [ProjectId: Int]())
            }
    }
    
    func comments(for project: Project) -> Future<[UserComment], DiscussionProviderError> {
        return Future(error: .generic(NotImplementedError()))
    }
}
