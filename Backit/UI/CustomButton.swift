/**
 * Provides a common way to retrieve customer user input.
 *
 * Required view configuration in xib:
 * - Set background to `Default` (?)
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

protocol CustomButton: UIControl {
    func view(at point: CGPoint, with event: UIEvent?) -> UIView?
}

extension CustomButton {
    func view(at point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = subviews.reversed().first { (subview) -> Bool in
            let subPoint = subview.convert(point, to: self)
            return subview.hitTest(subPoint, with: event) != nil
        }
        return view == nil ? nil : self
    }
}
