/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import BrightFutures

enum ProjectProviderError: Error {
    case generic(Error)
}

struct Filter {
    
}

protocol ProjectProvider {
    /// Get all projects for a creator
    /// Get all this user's favorited projects
    /// Get a specific project by project ID - passed via notification or other marketing avenue
    /// Get personalized projects for this user
    /// Get projects that are about to fund (optional: category, subcategory)
    
    func project(id: Any) -> Future<Project, ProjectProviderError>
    
    /**
     Perform an advanced search for projects.
     */
    func projects(offset: Any?, limit: Int) -> Future<ProjectResponse, ProjectProviderError>
    
    /**
     Get the latest projects for a given filter.
     */
    func projects(filter: Filter, offset: Any?, limit: Int) -> Future<ProjectResponse, ProjectProviderError>
    
    /**
     Get the most popular projects which are currently funding.
     */
    func popularProjects(offset: Any?, limit: Int) -> Future<ProjectResponse, ProjectProviderError>
    
    /**
     Up vote a project.
     */
    func upVote(project: Project) -> Future<IgnorableValue, ProjectProviderError>
    
    /**
     Remove a vote from a project.
     */
    func removeVote(from project: Project) -> Future<IgnorableValue, ProjectProviderError>
}
