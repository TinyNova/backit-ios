/**
 * Provides a common way to retrieve customer user input.
 *
 * Required view configuration in xib:
 *  - Set `Clips to Bounds` to `true`
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

    private var height: CGFloat = 50.0
    
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
        titleLabelTopConstraint.constant = ceil(height / CGFloat(2.0))
    }
}

extension TextEntryField: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        layoutIfNeeded()
        
        let scaleTransform = titleLabel.transform.scaledBy(x: 0.5, y: 0.50)
        let frame = titleLabel.frame
        var scaleFrame = frame
        scaleFrame.size.width *= 0.5
        scaleFrame.size.height *= 0.5
        scaleFrame.origin.x = frame.size.width * 0.5 * 0.5
        scaleFrame.origin.y = frame.size.height * 0.5 * 0.5
        
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            guard let sself = self else {
                return
            }

            sself.titleLabel.transform = scaleTransform
            sself.titleLabel.frame = scaleFrame
//            finalFrame = sself.titleLabel.frame
            
            sself.titleLabelTopConstraint.constant = ceil(sself.height * CGFloat(0.1))
            sself.layoutIfNeeded()
        }) { [weak self] _ in
            self?.titleLabel.frame = scaleFrame
        }
        
        return true
    }
}
