/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

private func url(for string: String?) -> URL? {
    guard let string = string else {
        return nil
    }
    return URL(string: string)
}


extension ProjectResponse {
    
    static private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        // "2019-04-23T19:00:05.000Z"
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }()
    
    init(from response: ProjectsEndpoint.ResponseType, cursor: Int) {
        self.cursor = cursor
        self.projects = response.projects.map { (project) -> Project in
            // FIXME: This should be an image local to the project
            var imageURL: URL = URL(string: "http://placekitten.com/200/300")!
            if let thumbnailURL = url(for: project.image?.thumbnail) {
                imageURL = thumbnailURL
            }
            let goal = project.goal
            let pledged = project.pledged
            
            let source: ProjectSource
            switch project.site?.lowercased() {
            case "kickstarter":
                source = .kickstarter
            case "indiegogo":
                source = .indiegogo
            default:
                source = .unknown
            }
            
            let dateFormatter = ProjectResponse.dateFormatter
            var daysLeft: Int = 0
            if let fundEnd = project.fundEnd,
               let fundingEndDate = dateFormatter.date(from: fundEnd) {
                let calendar = NSCalendar.current
                let components = calendar.dateComponents([.day], from: Date(), to: fundingEndDate)
                if let day = components.day, day > -1 {
                    daysLeft = day
                }
            }
            
            return Project(
                id: project.projectId ?? 0,
                source: source,
                externalUrl: url(for: project.url),
                internalUrl: url(for: project.internalUrl),
                name: project.name ?? "",
                goal: goal ?? 0,
                pledged: pledged ?? 0,
                numBackers: project.backerCount ?? 0,
                imageURLs: [imageURL],
                videoPreviewURL: nil,
                videoURL: url(for: project.url),
                numEarlyBirdRewards: project.earlyBirdRewardCount ?? 0,
                funded: project.funded ?? false,
                numDaysLeft: daysLeft,
                numVotes: 0
            )
        }
    }
}
