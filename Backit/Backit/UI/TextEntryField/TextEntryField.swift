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

class TextEntryField: UIView {
    
    @IBOutlet weak var titleLabelTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            theme.apply(.title, toLabel: titleLabel)
            titleLabel.textAlignment = .left
        }
    }
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            theme.apply(.normal, toTextField: textField)
            textField.delegate = self
        }
    }
    
    public var text: String? {
        return textField.text
    }
    
    let i18n = Localization<Appl10n>()
    let theme: UIThemeApplier<AppTheme> = AppTheme.default

    private var labelIsSmall = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public func configure(title: String, isSecure: Bool) {
        titleLabel.text = title
        textField.isSecureTextEntry = isSecure
    }
    
    private func setup() {
        guard let view = fromNib() else {
            return
        }
        
        view.backgroundColor = UIColor.fromHex(0x241a50)
        view.clipsToBounds = true
        view.layer.cornerRadius = 4.0
        
        // FIXME: This constraint may need to be set in layout pass when we know the height of the view.
//        height = view.frame.size.height
        titleLabelTopConstraint.constant = ceil(50.0 / CGFloat(2.0))
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(focusTextField))
        gestureRecognizers = [gesture]
    }
    
    @objc private func focusTextField(_ sender: Any) {
        guard !textField.isFirstResponder else {
            return
        }
        textField.becomeFirstResponder()
    }
}

extension TextEntryField: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard !labelIsSmall else {
            return true
        }

        labelIsSmall = true
        layoutIfNeeded()
        
        var scaleTransform = titleLabel.transform.scaledBy(x: 0.5, y: 0.5)
        scaleTransform = scaleTransform.translatedBy(x: -50.0, y: -6.0)

        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let sself = self else {
                return
            }

            sself.titleLabel.transform = scaleTransform            
            sself.titleLabelTopConstraint.constant = ceil(50.0 * CGFloat(0.1))
            sself.layoutIfNeeded()
        }
        
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard labelIsSmall && textField.text?.count == 0 else {
            return
        }

        labelIsSmall = false
        layoutIfNeeded()

        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let sself = self else {
                return
            }

            sself.titleLabel.transform = CGAffineTransform.identity
            sself.titleLabelTopConstraint.constant = ceil(50.0 / CGFloat(2.0))
            sself.layoutIfNeeded()
        }
    }
}
