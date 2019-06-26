/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

class ProjectService: ProjectProvider {
    
    private let service: Service
    
    init(service: Service) {
        self.service = service
    }
    
    func projects(offset: Any?, limit: Int) -> Future<ProjectResponse, ProjectProviderError> {
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
            .map { response -> ProjectResponse in
                return ProjectResponse(from: response, cursor: nextCursor)
            }
            .mapError { error -> ProjectProviderError in
                return .generic(error)
            }
    }
}
