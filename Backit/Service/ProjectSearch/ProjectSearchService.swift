import BrightFutures
import Foundation

class ProjectSearchService: ProjectSearchProvider {
    
    private let service: Service
    private let categoryProvider: CategoryProvider
    private let transformer: ProjectTransformer

    private var categories: [Category]?
    
    init(service: Service, categoryProvider: CategoryProvider, transformer: ProjectTransformer = .init()) {
        self.service = service
        self.categoryProvider = categoryProvider
        self.transformer = transformer
    }

    func resultsFor(token: String?, hasEarlyBirdRewards: Bool) -> Future<ProjectSearchResult, ProjectSearchProviderError> {
        var projectsFuture: Future<ProjectResult?, Never>
        if let token = token {
            projectsFuture = projectsFor(token: token, hasEarlyBirdRewards: hasEarlyBirdRewards)
        }
        else {
            projectsFuture = Future(value: nil)
        }
        // Use cached categories
        if let categories = categories {
            return Future(value: ProjectSearchResult(
                categories: filterCategories(categories, using: token),
                subcategories: [],
                keywords: [],
                projects: projectsFuture
            ))
        }
        // Query for categories
        return categoryProvider.categories()
            .map { [weak self] (categories) -> ProjectSearchResult in
                self?.categories = categories
                return ProjectSearchResult(
                    categories: filterCategories(categories, using: token),
                    subcategories: [],
                    keywords: [],
                    projects: projectsFuture
                )
            }
            .mapError { error -> ProjectSearchProviderError in
                return .generic(error)
            }
    }
    
    func projectsFor(token: String, hasEarlyBirdRewards: Bool) -> Future<ProjectResult?, Never> {
        let params: [ProjectSearchEndpoint.QueryParameter] = [
            .hasEarlyBirdRewards(hasEarlyBirdRewards),
            .query(token)
        ]
        let endpoint = ProjectSearchEndpoint(params)
        return service.request(endpoint, debug: true)
            .map { [transformer] (result) -> ProjectResult in
                return transformer.transform(from: result)
            }
            .recover { (error) -> ProjectResult? in
                return nil
            }
    }
        
    // TODO: Projects by category and filters
    // TODO: Projects by subcategory and filters
    // TODO: Projects by keyword and filters
    
    // Keyword is a grouping of the most common labels returned for a result set. Such that, if they search for "futuristic table top games", and most of those results are tagged with "dystopian", then one of the keywords would be "dystopian".
}

/// Filter categories for a given search term
private func filterCategories(_ categories: [Category], using term: String?) -> [Category] {
    // This should never happen. If it does, it should return the top 3 most searched categories.
    // TODO: Potentially only filter queries if the term is >= 3 characters.
    guard let term = term else {
        return Array(categories.prefix(3))
    }
    let topHitCategories = categories.filter { (category) -> Bool in
        return category.name.lowercased().contains(term.lowercased())
    }
    return Array(topHitCategories.prefix(3))
}

class ProjectTransformer {
    
    func transform(from response: ProjectSearchEndpoint.ResponseType) -> ProjectResult {
        // this should contain limit/count/etc.
        let projects = response.projects.map { (project) -> Project in
            var imageUrls = [URL]()
            if let url = URL.make(from: project.image.card) {
                imageUrls.append(url)
            }
            
            let daysLeft: Int = numDaysLeft(
                fundStart: ProjectService.dateFrom(project.fundStart),
                fundEnd: ProjectService.dateFrom(project.fundEnd)
            )

            return Project(
                id: ProjectId(project.projectId),
                source: ProjectSource.makeFromSiteName(project.site),
                externalUrl: nil,
                internalUrl: nil,
                name: project.name ?? "",
                goal: project.goal ?? 0,
                pledged: project.pledged ?? 0,
                numBackers: project.backerCount ?? 0,
                imageURLs: imageUrls,
                videoPreviewURL: URL.make(from: project.image.card),
                videoURL: URL.make(from: project.video?.streaming?.mobile),
                numEarlyBirdRewards: project.earlyBirdRewardCount ?? 0,
                funded: project.funded ?? false,
                numDaysLeft: daysLeft,
                numVotes: project.votes ?? 0
            )
        }
        return ProjectResult(
            total: 0,
            offset: 0,
            limit: 0,
            sort: .init(key: "", direction: ""),
            projects: projects
        )
    }
}
