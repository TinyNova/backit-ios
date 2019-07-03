/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

protocol ProjectVoteProvider {
    func votedFor(project: Project) -> Future<Bool, Error>
    func voteFor(project: Project) -> Future<IgnorableValue, Error>
}
