/**
 *
 * Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Foundation
import UIKit

public protocol ViewIdentifiable {
    func toString() -> String
}

extension ViewIdentifiable {
    
    /**
     Returns a string representation of `self`.
     */
    func toString() -> String {
        return String(reflecting: self)
    }
}

extension UIView {
    public var identifier: ViewIdentifiable? {
        get {
            return nil
        }
        set {
            accessibilityIdentifier = newValue?.toString()
        }
    }
}
