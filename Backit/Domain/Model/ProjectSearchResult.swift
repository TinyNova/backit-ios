import BrightFutures
import Foundation

struct ProjectSearchResult {
    let categories: [Category]
    let subcategories: [Category]
    let keywords: [String]
    let projects: Future<[Project], NoError>
}
