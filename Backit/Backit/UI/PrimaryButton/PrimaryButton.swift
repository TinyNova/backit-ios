/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

class PrimaryButton: UIControl, CustomButton {
    
    @IBOutlet private weak var textLabel: UILabel! {
        didSet {
            theme.apply(.primaryButton, toLabel: textLabel)
        }
    }
    
    public var title: String? {
        get {
            return textLabel.text
        }
        set {
            textLabel.text = newValue
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

        view.backgroundColor = UIColor.fromHex(0x1b96f1)
        view.clipsToBounds = true
        view.layer.cornerRadius = 4.0
        view.superview?.backgroundColor = UIColor.clear
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return view(at: point, with: event)
    }
}
