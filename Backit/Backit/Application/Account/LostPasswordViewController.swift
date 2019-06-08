/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

class LostPasswordViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = i18n.t(.createAnAccount)
            theme.apply(.loginHeader, toLabel: titleLabel)
        }
    }
    @IBOutlet weak var emailField: TextEntryField! {
        didSet {
            emailField.configure(title: i18n.t(.email), type: .email)
        }
    }
    @IBOutlet weak var errorLabel: UILabel! {
        didSet {
            errorLabel.isHidden = true
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

    func inject(accountProvider: AccountProvider) {
        self.accountProvider = accountProvider
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.fromHex(0x130a33)
    }

    @IBAction func didTapResetPasswordButton(_ sender: Any) {
        guard let email = emailField.text else {
            errorLabel.isHidden = false
            errorLabel.text = "Please enter your email"
            return
        }

        errorLabel.isHidden = true

        accountProvider?.resetPassword(email: email)
            .onSuccess { [weak self] _ in
                UIView.animate(withDuration: 0.3, animations: {
                    self?.informationTextView.text = self?.i18n.t(.passwordSuccessfullyReset)
                })
            }
            .onFailure { [weak self] (error) in
                self?.errorLabel.isHidden = false
                self?.errorLabel.text = error.localizedDescription
            }
    }
}
