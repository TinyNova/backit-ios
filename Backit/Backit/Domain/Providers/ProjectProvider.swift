/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import BrightFutures

enum ProjectProviderError: Error {
    case failedToLoadProject
}

protocol ProjectProvider {
    func projects(offset: Any?, limit: Int) -> Future<ProjectResponse, ProjectProviderError>
}
