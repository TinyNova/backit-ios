/**
 https://www.raywenderlich.com/250-internationalizing-your-ios-app-getting-started
 */

import Foundation

enum Appl10n {
    case hello
    case salutation(name: String, age: Int)
}

extension Appl10n: LocalizationType {
    func localize() -> String {
        switch self {
        case .hello:
            return l(key: "hello")
        case .salutation(let name, let age):
            return l(key: "salutation(name,age)", arguments: name, number(age))
        }
    }
}
