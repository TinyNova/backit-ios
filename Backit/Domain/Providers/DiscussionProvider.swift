/**
 * Provides all features related to user discussions around a Project.
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

struct UserComment {
    
}

enum DiscussionValidationField {
    case projectIds
}

enum DiscussionProviderError: Error {
    case generic(Error)
    case incompatibleProjectId
    case server(message: String?, metadata: [String: [String]]?)
}

protocol DiscussionProvider {
    func comments(for project: Project) -> Future<[UserComment], DiscussionProviderError>
    func commentCount(for projects: [Project]) -> Future<[ProjectId: Int], DiscussionProviderError>
    func commentCount(for project: Project) -> Future<Int, DiscussionProviderError>
}
