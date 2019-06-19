/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

class log {
    class func i(_ message: String) {
        print("INFO: \(message)")
    }

    class func w(_ message: String) {
        print("WARN: \(message)")
    }

    class func e(_ message: String) {
        print("ERROR: \(message)")
    }
    class func e(_ error: Error) {
        print("ERROR: \(error)")
    }
    
    class func c(_ message: String) {
        print("CRITICAL: \(message)")
    }
}
