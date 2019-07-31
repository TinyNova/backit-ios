import Foundation

extension DetailedProject {
    
    init(from response: DetailedProjectInfoEndpoint.ResponseType) {
        self.id = response.projectId ?? 0
        switch response.site?.siteId {
        case 1:
            self.source = .kickstarter
        case 2:
            self.source = .indiegogo
        default:
            self.source = .unknown
        }
        self.externalUrl = response.url
        self.internalUrl = response.internalUrl
        self.name = response.name ?? ""
        self.goal = response.goal ?? 0
        self.pledged = response.pledged ?? 0
        self.numBackers = response.backerCount ?? 0
        self.author = Author(
            name: response.creator?.name ?? "",
            avatarUrl: response.creator?.avatar
        )
        self.category = response.category?.name ?? ""
        self.country = response.country?.name ?? ""
        self.blurb = response.blurb ?? ""
        self.text = response.projectText ?? ""
        self.rewards = response.rewards?.map { (reward: DetailedProjectInfoEndpoint.Reward) -> Reward in
            return Reward(
                name: reward.description ?? "",
                cost: Double(reward.amount ?? 0),
                numberOfBackers: 0,
                total: 0
            )
        } ?? []
        self.imageUrl = nil
        self.videoUrl = nil
    }
}
