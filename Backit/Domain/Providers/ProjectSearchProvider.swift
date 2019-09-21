import BrightFutures
import Foundation

enum ProjectSearchProviderError: Error {
    case generic
}

protocol ProjectSearchProvider {
    func resultsFor(token: String) -> Future<ProjectSearchResult, ProjectSearchProviderError>
}
