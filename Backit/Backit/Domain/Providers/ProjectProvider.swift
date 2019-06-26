/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import BrightFutures

enum ProjectProviderError: Error {
    case generic(Error)
}

protocol ProjectProvider {
    func projects(offset: Any?, limit: Int) -> Future<ProjectResponse, ProjectProviderError>
}
