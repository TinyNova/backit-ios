/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

protocol DatabaseProvider {
    func didVoteForProject(project: Project) -> Bool
    func voteForProject(project: Project) -> Bool
    func removeVoteFromProject(project: Project) -> Bool
}
