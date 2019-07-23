/**
 Supported environments for this app.
 
 This file aims to be represent most app environments. However, it may need to be updated to reflect your respective system environments. It may also need to include `test` or `preview` environments.
 
 License: MIT
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

struct Environment: OptionSet, Hashable {
    let rawValue: Int
    
    var hashValue: Int {
        return self.rawValue
    }
    
    static let dev = Environment(rawValue: 1 << 0)
    static let qa = Environment(rawValue: 1 << 1)
    static let prod = Environment(rawValue: 1 << 2)
    
    static let all: Environment = [.dev, .qa, .prod]
    
    static func ==(lhs: Environment, rhs: Environment) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}


