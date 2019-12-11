import BrightFutures
import Foundation

enum ProjectSearchError: Error {
    case generic(Error)
}

struct ProjectResult {
    struct Sort {
        let key: String
        let direction: String
    }
    
    let total: Int
    let offset: Int
    let limit: Int
    let sort: ProjectResult.Sort
    let projects: [Project]
}

struct ProjectSearchResult {
    let categories: [Category]
    let subcategories: [Category]
    let keywords: [String]
    let projects: Future<ProjectResult?, Never>
}
