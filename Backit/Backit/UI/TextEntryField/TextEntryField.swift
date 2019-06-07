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

enum TextEntryFieldType {
    case `default`
    case email
    case numeric
    case phoneNumber
    case password
}

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

    /**
     * Configure how the text entry accepts data input.
     *
     * This should only be called once.
     */
    public func configure(title: String, type: TextEntryFieldType) {
        titleLabel.text = title

        switch type {
        case .default:
            break
        case .email:
            textField.keyboardType = .emailAddress
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
        case .phoneNumber:
            textField.keyboardType = .phonePad
        case .numeric:
            textField.keyboardType = .decimalPad
        case .password:
            textField.isSecureTextEntry = true
        }
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
        view.gestureRecognizers = [gesture]
    }
    
    @objc private func focusTextField(_ sender: Any) {
        guard !textField.isFirstResponder else {
            return
        }
        textField.becomeFirstResponder()
    }
}

extension TextEntryField: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard !labelIsSmall else {
            return
        }

        labelIsSmall = true
        layoutIfNeeded()

        var scaleTransform = titleLabel.transform.scaledBy(x: 0.7, y: 0.7)
        scaleTransform = scaleTransform.translatedBy(x: -22.0, y: -2.0)

        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let sself = self else {
                return
            }

            sself.titleLabel.transform = scaleTransform
            sself.titleLabelTopConstraint.constant = ceil(50.0 * CGFloat(0.1))
            sself.layoutIfNeeded()
        }
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
