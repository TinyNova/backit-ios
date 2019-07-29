import Foundation

extension DetailedProject {
    
    init(from response: DetailedProjectInfoEndpoint.ResponseType) {
        self.id = 1
        self.source = .kickstarter
        self.externalUrl = nil
        self.internalUrl = nil
        self.name = ""
        self.goal = 0
        self.pledged = 0
        self.numBackers = 0
        self.author = Author(name: "", avatarUrl: nil)
        self.category = ""
        self.country = ""
        self.blurb = ""
        self.text = ""
        self.rewards = [Reward]()
        self.imageUrl = nil
        self.videoUrl = nil
    }
}
