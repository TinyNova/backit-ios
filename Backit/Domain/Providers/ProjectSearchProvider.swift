import BrightFutures
import Foundation

enum ProjectSearchProviderError: Error {
    case generic(Error)
}

protocol ProjectSearchProvider {
    func resultsFor(token: String?, hasEarlyBirdRewards: Bool) -> Future<ProjectSearchResult, ProjectSearchProviderError>
}
