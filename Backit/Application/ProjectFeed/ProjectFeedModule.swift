import Foundation

enum ProjectFeedModule {
    enum HeroId {
        static func projectImage(_ id: Int?) -> String {
            return "ProjectImage\(id ?? 0)"
        }
        
        static func projectName(_ id: Int?) -> String {
            return "ProjectName\(id ?? 0)"
        }
    }
}
