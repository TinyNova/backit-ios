import Foundation

extension ProjectResponse {
    init(from response: ProjectService.ProjectRequest.ResponseType, offset: Int) {
        self.offset = offset
        self.projects = response.projects.map { (project) -> Project in
            // FIXME: This should be an image local to the project
            var imageURL: URL = URL(string: "http://placekitten.com/200/300")!
            if let thumbnailURL = URL(string: project.image.t) {
                imageURL = thumbnailURL
            }
            
            return Project(
                id: 1,
                source: .kickstarter,
                url: nil,
                name: "Name",
                goal: 0,
                pledged: 0,
                numBackers: 0,
                imageURLs: [imageURL],
                videoPreviewURL: nil,
                videoURL: nil,
                hasEarlyBirdRewards: false,
                funded: false
            )
        }
    }
}
