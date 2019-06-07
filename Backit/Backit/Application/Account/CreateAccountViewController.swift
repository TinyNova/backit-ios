/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

class CreateAccountViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = i18n.t(.createAnAccount)
            theme.apply(.loginHeader, toLabel: titleLabel)
        }
    }
    @IBOutlet weak var emailField: TextEntryField! {
        didSet {
            emailField.configure(title: i18n.t(.email), isSecure: false)
        }
    }
    @IBOutlet weak var usernameField: TextEntryField! {
        didSet {
            usernameField.configure(title: i18n.t(.username), isSecure: false)
        }
    }
    @IBOutlet weak var passwordField: TextEntryField! {
        didSet {
            passwordField.configure(title: i18n.t(.password), isSecure: true)
        }
    }
    @IBOutlet weak var errorLabel: UILabel! {
        didSet {
            errorLabel.isHidden = true
        }
    }
    @IBOutlet weak var legalTextView: UITextView! {
        didSet {
            legalTextView.delegate = self
            legalTextView.text = i18n.t(.byContinuingYouAgree)
            theme.apply(.legal, toTextView: legalTextView)
            theme.apply(.link(needle: i18n.t(.termsOfService), href: "https://backit.com/terms"), toTextView: legalTextView)
            theme.apply(.link(needle: i18n.t(.privacyPolicy), href: "https://backit.com/policies"), toTextView: legalTextView)
        }
    }
    @IBOutlet weak var createAccountButton: PrimaryButton! {
        didSet {
            createAccountButton.title = i18n.t(.createAccount)
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

    @IBAction func didTapCreateAccount(_ sender: Any) {
        print("Did tap create account")
    }
}

extension CreateAccountViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
}
