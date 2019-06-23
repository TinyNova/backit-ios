/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

enum LogLevel: Int {
    case info
    case warning
    case error
    case critical
}

class log {
    
    static var level: LogLevel = .info
    
    class func i(_ message: String) {
        guard log.level < .warning else {
            return
        }
        print("INFO: \(message)")
    }

    class func w(_ message: String) {
        guard log.level < .error else {
            return
        }
        print("WARN: \(message)")
    }

    class func e(_ message: String) {
        guard log.level < .critical else {
            return
        }
        print("ERROR: \(message)")
    }
    class func e(_ error: Error) {
        guard log.level < .critical else {
            return
        }
        print("ERROR: \(error)")
    }
    
    class func c(_ message: String) {
        print("CRITICAL: \(message)")
    }
}

private func <<T: RawRepresentable>(a: T, b: T) -> Bool where T.RawValue: Comparable {
    return a.rawValue < b.rawValue
}
