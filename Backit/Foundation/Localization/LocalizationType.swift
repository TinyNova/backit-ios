/**
 Provides ability to make requests.
 
 License: MIT
 
 Copyright © 2019 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

public protocol LocalizationType {
    func localize() -> String
}

extension LocalizationType {
    func l(key: String, comment: String = "", arguments: CVarArg...) -> String {
        let string = NSLocalizedString(key, comment: comment)
        return String(format: string, arguments: arguments)
    }
    
    func number(_ number: Int) -> NSNumber {
        return NSNumber(value: number)
    }
    
    func number(_ number: Float) -> NSNumber {
        return NSNumber(value: number)
    }
    
    func localizedNumber(_ number: Int, type: NumberFormatter.Style = .decimal) -> String {
        return NumberFormatter.localizedString(from: NSNumber(value: number), number: type)
    }
}
