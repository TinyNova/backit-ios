/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

class ProjectService: ProjectProvider {
    
    static private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        // "2019-04-23T19:00:05.000Z"
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }()
    
    private let service: Service
    
    init(service: Service) {
        self.service = service
    }
    
    func project(id: ProjectId) -> Future<DetailedProject, ProjectProviderError> {
        let endpoint = DetailedProjectInfoEndpoint(projectId: id)
        return service.request(endpoint)
            .map { (response) -> DetailedProject in
                return DetailedProject(from: response)
            }
            .mapError{ (error) -> ProjectProviderError in
                return .generic(error)
            }
    }
    
    func projects(offset: Any?, limit: Int) -> Future<ProjectResponse, ProjectProviderError> {
        return Future(error: .generic(NotImplementedError()))
    }
    
    func projects(filter: Filter, offset: Any?, limit: Int) -> Future<ProjectResponse, ProjectProviderError> {
        return Future(error: .generic(NotImplementedError()))
    }
    
    func popularProjects(offset: Any?, limit: Int) -> Future<ProjectResponse, ProjectProviderError> {
        let nextCursor: Int
        if let offset = offset as? Int {
            nextCursor = offset + limit
        }
        else {
            nextCursor = 0
        }
        
        let request = ProjectsEndpoint(queryParameters: [
            .funding(true),
            .backerCountMin(100),
            .country("United States"),
            .sort("backerCount"),
            .sortDirection("desc"),
            .offset(nextCursor),
            .limit(limit)
        ])
        return service.request(request)
            .map { (response) -> ProjectResponse in
                return ProjectResponse(from: response, cursor: nextCursor)
            }
            .mapError { error -> ProjectProviderError in
                return .generic(error)
            }
    }

    func upVote(project: Project) -> Future<IgnorableValue, ProjectProviderError> {
        let endpoint = UpVoteProjectEndpoint(postBody: [
            .projectId(project.id),
            .vote("up")
        ])

        return service.request(endpoint)
            .map { (data) -> IgnorableValue in
                return IgnorableValue()
            }
            .mapError { (error) -> ProjectProviderError in
                return .generic(error)
            }
    }

    func removeVote(from project: Project) -> Future<IgnorableValue, ProjectProviderError> {
        let endpoint = RemoveVoteEndpoint(pathParameters: [
            .projectId(project.id)
        ])
        
        return service.request(endpoint, debug: true)
            .map { (data) -> IgnorableValue in
                return IgnorableValue()
            }
            .mapError { (error) -> ProjectProviderError in
                return .generic(error)
            }
    }
    
    // MARK: - Internal Methods
    
    static func dateFrom(_ dateString: String?) -> Date? {
        guard let dateString = dateString else {
            return nil
        }
        return ProjectService.dateFormatter.date(from: dateString)
    }
}
