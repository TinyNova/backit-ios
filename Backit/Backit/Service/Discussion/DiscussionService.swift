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
        return Future(error: .generic(NotImplementedError()))
//        service.debug = true
        return service.request(endpoint)
//            .recover { (error) -> CommentCountEndpoint.ResponseType in
//                return Data()
//            }
            .mapError { (error) -> DiscussionProviderError in
                return .generic(error)
            }
            .flatMap { (response) -> Future<Int, DiscussionProviderError> in
//                if let message = response.message {
//                    return Future(error: validationError(
//                        message: message,
//                        validation: response.validation
//                    ))
//                }
                return Future(value: response.value ?? 0)
            }
    }
    
    func commentCount(forAll projects: [Project]) -> Future<[ProjectId : Int], DiscussionProviderError> {
        return Future(error: .generic(NotImplementedError()))
    }
    
    func comments(for project: Project) -> Future<[UserComment], DiscussionProviderError> {
        return Future(error: .generic(NotImplementedError()))
    }
}

private func validationError(message: String, validation: [String: [String]]?) -> DiscussionProviderError {
    var metadata = [String]()
    validation?.forEach { (record: (key: String, value: [String])) in
        metadata.append("\(record.key): \(record.value)")
    }
    return .validation(message: message, metadata: metadata)
}
