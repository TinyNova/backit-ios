import BrightFutures
import Foundation

class ProjectSearchService: ProjectSearchProvider {
    
    private let service: Service
    private let categoryProvider: CategoryProvider
    private let transformer: ProjectTransformer

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
        return categoryProvider.categories()
            .map { (categories) -> ProjectSearchResult in
                return ProjectSearchResult(
                    categories: [],
                    subcategories: [],
                    keywords: [],
                    projects: projectsFuture
                )
            }
            .mapError { error -> ProjectSearchProviderError in
                return .generic(error)
            }

//        return Future(value: ProjectSearchResult(
//            categories: [Category(id: 1, name: "Board Games")],
//            subcategories: [],
//            keywords: [],
//            projects: Future(value: [Project(id: 1, source: .kickstarter, externalUrl: nil, internalUrl: nil, name: "Starlight", goal: 100, pledged: 50, numBackers: 4, imageURLs: [], videoPreviewURL: nil, videoURL: nil, numEarlyBirdRewards: 5, funded: false, numDaysLeft: 2, numVotes: 4)])
//        ))
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
    
    // Keyword is a grouping of the most common types which all projects in the current result set belong to.
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
