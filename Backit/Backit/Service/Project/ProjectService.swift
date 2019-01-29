/**
 *
 * Copyright © 2018 Backit. All rights reserved.
 */

import BrightFutures
import Foundation

class ProjectService: Service, ProjectProvider {
    
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
        return self.request(request)
            .map { response -> ProjectResponse in
                return ProjectResponse(from: response, cursor: nextCursor)
            }
            .mapError { error -> ProjectProviderError in
                return .failedToLoadProject
            }
    }
}
