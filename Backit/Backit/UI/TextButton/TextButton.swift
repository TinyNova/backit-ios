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

class TextButton: UIButton {

    public var title: String? {
        get {
            return title(for: .normal)
        }
        set {
            setTitle(newValue, for: .normal)
        }
    }

    let theme: UIThemeApplier<AppTheme> = AppTheme.default

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    private func setup() {
        guard let view = fromNib() else {
            return
        }

        theme.apply(.text, toButton: self)

        view.backgroundColor = UIColor.fromHex(0x1b96f1)
        view.clipsToBounds = true
        view.layer.cornerRadius = 4.0
        view.superview?.backgroundColor = UIColor.clear
    }
//
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        let view = subviews.reversed().first { (subview) -> Bool in
//            let subPoint = subview.convert(point, to: self)
//            return subview.hitTest(subPoint, with: event) != nil
//        }
//        return view == nil ? nil : self
//    }
}
