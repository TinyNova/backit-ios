/**
 https://www.raywenderlich.com/250-internationalizing-your-ios-app-getting-started
 */

import Foundation

enum Appl10n {
    case comment
    case comments(amount: Int)
    case funded(amount: Int)
    case loadingProjects
    case youreUpToDate
    case errorLoadingProjects
    case `continue`
}

extension Appl10n: LocalizationType {
    func localize() -> String {
        switch self {
        case .comment:
            return l(key: "comment")
        case .comments(let amount):
            return l(key: "comments(amount)", arguments: number(amount))
        case .funded(let amount):
            return l(key: "funded", arguments: number(amount))
        case .loadingProjects:
            return l(key: "loadingProjects")
        case .youreUpToDate:
            return l(key: "youreUpToDate")
        case .errorLoadingProjects:
            return l(key: "errorLoadingProjects")
        case .continue:
            return l(key: "continue")
        }
    }
}
