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
    
    public static func < (a: LogLevel, b: LogLevel) -> Bool {
        return a.rawValue < b.rawValue
    }
}

var log = Logger()

class Logger {
    
    var level: LogLevel = .info
    
    func i(_ message: String) {
        guard log.level < .warning else {
            return
        }
        print("INFO: \(message)")
    }

    func w(_ message: String) {
        guard log.level < .error else {
            return
        }
        print("WARN: \(message)")
    }

    func e(_ message: String) {
        guard log.level < .critical else {
            return
        }
        print("ERROR: \(message)")
    }
    func e(_ error: Error) {
        guard log.level < .critical else {
            return
        }
        print("ERROR: \(error)")
    }
    
    func c(_ message: String) {
        print("CRITICAL: \(message)")
    }
}
