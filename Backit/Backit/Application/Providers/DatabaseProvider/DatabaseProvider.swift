/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

protocol DatabaseProvider {
    func didVoteForProject(_ project: Project) -> Bool
    func voteForProject(_ project: Project)
    func removeVoteFromProject(_ project: Project)
}
