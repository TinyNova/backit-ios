/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

class TextButton: UIControl, CustomButton {
    
    @IBOutlet private weak var textLabel: UILabel! {
        didSet {
            theme.apply(.textButton, toLabel: textLabel)
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
        
        view.backgroundColor = UIColor.clear
        view.superview?.backgroundColor = UIColor.clear
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return view(at: point, with: event)
    }
}
