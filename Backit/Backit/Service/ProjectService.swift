/**
 *
 * Copyright © 2018 Backit. All rights reserved.
 */

import BrightFutures
import Foundation

class ProjectService: Service, ProjectProvider {
    
    func projects(offset: Any?) -> Future<ProjectResponse, ProjectProviderError> {
        let nextOffset: Int
        if let offset = offset as? Int {
            nextOffset = offset + 10
        }
        else {
            nextOffset = 0
        }
        
        let request = ProjectRequest(parameters: [
            .funding(true),
            .backerCountMin(100),
            .country("United States"),
            .sort("backerCount"),
            .sortDirection("desc"),
            .offset(nextOffset),
            .limit(10)
        ])
        return self.request(request)
            .map { response -> ProjectResponse in
                return ProjectResponse(from: response, offset: nextOffset)
            }
            .mapError { error -> ProjectProviderError in
                return .failedToLoadProject
            }
    }
}
