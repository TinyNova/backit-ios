/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

extension URL {
    static func make(from string: String?) -> URL? {
        guard let string = string else {
            return nil
        }
        return URL(string: string)
    }
}

func numDaysLeft(fundStart: Date?, fundEnd: Date?) -> Int {
    guard let fundStart = fundStart, let fundEnd = fundEnd else {
        return 0
    }
    let calendar = Calendar.current
    let dateStart = calendar.startOfDay(for: fundStart)
    let dateEnd = calendar.startOfDay(for: fundEnd)
    let components = calendar.dateComponents([.day], from: dateStart, to: dateEnd)
    return components.day ?? 0
}

extension ProjectSource {
    static func makeFromSiteName(_ siteName: String?) -> ProjectSource {
        switch siteName?.lowercased() {
        case "kickstarter":
            return .kickstarter
        case "indiegogo":
            return .indiegogo
        default:
            return .unknown
        }

    }
}

extension ProjectResponse {
    init(from response: ProjectsEndpoint.Response, cursor: Int) {
        self.cursor = cursor
        self.projects = response.projects.map { (project) -> Project in
            // FIXME: This should be an image local to the project
            var imageURL: URL = URL(string: "http://placekitten.com/200/300")!
            if let thumbnailURL = URL.make(from: project.image?.thumbnail) {
                imageURL = thumbnailURL
            }
            let goal = project.goal
            let pledged = project.pledged
            
            let source = ProjectSource.makeFromSiteName(project.site)
            
            let daysLeft: Int = numDaysLeft(
                fundStart: ProjectService.dateFrom(project.fundStart),
                fundEnd: ProjectService.dateFrom(project.fundEnd)
            )

            return Project(
                id: project.projectId ?? 0,
                source: source,
                externalUrl: URL.make(from: project.url),
                internalUrl: URL.make(from: project.internalUrl),
                name: project.name ?? "",
                goal: goal ?? 0,
                pledged: pledged ?? 0,
                numBackers: project.backerCount ?? 0,
                imageURLs: [imageURL],
                videoPreviewURL: nil,
                videoURL: URL.make(from: project.url),
                numEarlyBirdRewards: project.earlyBirdRewardCount ?? 0,
                funded: project.funded ?? false,
                numDaysLeft: daysLeft,
                numVotes: project.votes ?? 0
            )
        }
    }
}
