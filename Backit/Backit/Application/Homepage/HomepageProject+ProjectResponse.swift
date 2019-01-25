import Foundation

extension HomepageProject {
    init(project: Project) {
        var assets: [ProjectAsset] = []
        assets.append(.image(project.imageURLs[0]))
        if let previewURL = project.videoPreviewURL, let videoURL = project.videoURL {
            assets.append(.video(previewURL: previewURL, videoURL: videoURL))
        }

        let fundedPercent = project.pledged > 0
            ? Float(project.pledged) / Float(project.goal)
            : 0

        self.context = 1
        self.source = project.source
        self.assets = assets
        self.name = project.name
        self.numberOfBackers = project.numBackers
        self.comment = .comment
        self.isEarlyBird = project.hasEarlyBirdRewards
        self.fundedPercent = fundedPercent

    }
}
