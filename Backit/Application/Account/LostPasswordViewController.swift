/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

import BKFoundation

class LostPasswordViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = i18n.t(.recoverPassword)
            theme.apply(.loginHeader, toLabel: titleLabel)
        }
    }
    @IBOutlet weak var emailField: TextEntryField! {
        didSet {
            emailField.configure(title: i18n.t(.email), type: .email, returnKeyType: .done)
            emailField.delegate = self
        }
    }
    @IBOutlet weak var informationTextView: UITextView! {
        didSet {
            informationTextView.text = i18n.t(.mustHaveProvidedEmail)
            theme.apply(.informational, toTextView: informationTextView)
        }
    }
    @IBOutlet weak var resetPasswordButton: PrimaryButton! {
        didSet {
            resetPasswordButton.title = i18n.t(.resetPassword)
        }
    }

    let i18n = Localization<Appl10n>()
    let theme: UIThemeApplier<AppTheme> = AppTheme.default

    var accountProvider: AccountProvider?
    var bannerProvider: BannerProvider?
    var overlay: ProgressOverlayProvider?

    func inject(accountProvider: AccountProvider, bannerProvider: BannerProvider, overlay: ProgressOverlayProvider) {
        self.accountProvider = accountProvider
        self.bannerProvider = bannerProvider
        self.overlay = overlay
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.fromHex(0x130a33)
    }

    @IBAction func didTapResetPasswordButton(_ sender: Any) {
        guard let email = emailField.text else {
            bannerProvider?.present(message: .error(title: nil, message: "Please enter your email"), in: self)
            return
        }
        
        overlay?.show()
        accountProvider?.resetPassword(email: email)
            .onSuccess { [weak self] _ in
                UIView.animate(withDuration: 0.3, animations: {
                    self?.bannerProvider?.present(message: BannerMessage(type: .info, title: nil, message: self?.i18n.t(.passwordSuccessfullyReset) ?? "", button1: nil, button2: nil), in: self)
                })
            }
            .onFailure { [weak self] (error) in
                self?.bannerProvider?.present(error: error, in: self)
            }
            .onComplete { [weak self] _ in
                self?.overlay?.dismiss()
            }
    }
}

extension LostPasswordViewController: TextEntryFieldDelegate {
    func didChangeText(field: TextEntryField, text: String?) {
        
    }
    
    func didSubmit(field: TextEntryField) {
        _ = field.resignFirstResponder()
        didTapResetPasswordButton(self)
    }
}
