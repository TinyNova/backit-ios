import Foundation

enum ProjectFeedModule {
    enum HeroId {
        static func projectImage(_ id: String?) -> String {
            return "ProjectImage\(id ?? "0")"
        }
        
        static func projectName(_ id: String?) -> String {
            return "ProjectName\(id ?? "0")"
        }
    }
}
