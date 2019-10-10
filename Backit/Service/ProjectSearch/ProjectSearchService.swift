import BrightFutures
import Foundation

class ProjectSearchService: ProjectSearchProvider {
    
    func resultsFor(token: String?) -> Future<ProjectSearchResult, ProjectSearchProviderError> {
        return Future(value: ProjectSearchResult(
            categories: [Category(id: 1, name: "Board Games")],
            subcategories: [Category(id: 1, name: "D&D")],
            keywords: ["Board Game", "Game"],
            projects: Future(value: [Project(id: 1, source: .kickstarter, externalUrl: nil, internalUrl: nil, name: "Starlight", goal: 100, pledged: 50, numBackers: 4, imageURLs: [], videoPreviewURL: nil, videoURL: nil, numEarlyBirdRewards: 5, funded: false, numDaysLeft: 2, numVotes: 4)])
        ))
    }
}
