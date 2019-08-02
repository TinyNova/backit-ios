/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

public enum LogLevel: Int {
    case debug
    case info
    case warning
    case error
    case critical
    
    public static func < (a: LogLevel, b: LogLevel) -> Bool {
        return a.rawValue < b.rawValue
    }
}

public var log = Logger()

public class Logger {
    
    public var level: LogLevel = .debug
    
    public func t(_ message: String) {
        print("TEST: \(message)")
    }
    public func d(_ message: String) {
        guard log.level < .info else {
            return
        }
        print("DEBUG: \(message)")
    }
    
    public func i(_ message: String) {
        guard log.level < .warning else {
            return
        }
        print("INFO: \(message)")
    }

    public func w(_ message: String) {
        guard log.level < .error else {
            return
        }
        print("WARN: \(message)")
    }

    public func e(_ message: String) {
        guard log.level < .critical else {
            return
        }
        print("ERROR: \(message)")
    }
    public func e(_ error: Error) {
        guard log.level < .critical else {
            return
        }
        print("ERROR: \(error)")
    }
    
    public func c(_ message: String) {
        print("CRITICAL: \(message)")
    }
}
