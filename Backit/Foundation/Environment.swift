/**
 Supported environments for this app.
 
 This file aims to be represent most app environments. However, it may need to be updated to reflect your respective system environments. It may also need to include `test` or `preview` environments.
 
 License: MIT
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

public struct Environment: OptionSet, Hashable {
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public init() {
        self = Environment.all
    }

    public let rawValue: Int
    
    public var hashValue: Int {
        return self.rawValue
    }
    
    public static let dev = Environment(rawValue: 1 << 0)
    public static let qa = Environment(rawValue: 1 << 1)
    public static let prod = Environment(rawValue: 1 << 2)
    
    public static let all: Environment = [.dev, .qa, .prod]
    
    public static func ==(lhs: Environment, rhs: Environment) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}


