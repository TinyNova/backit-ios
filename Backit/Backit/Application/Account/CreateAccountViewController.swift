/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

protocol CreateAccountViewControllerDelegate: class {
    func didCreateAccount(credentials: Credentials, userSession: UserSession)
    func userCancelled()
}

class CreateAccountViewController: UIViewController {

    weak var delegate: CreateAccountViewControllerDelegate?

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
    @IBOutlet weak var usernameField: TextEntryField! {
        didSet {
            usernameField.configure(title: i18n.t(.username), type: .default)
        }
    }
    @IBOutlet weak var passwordField: TextEntryField! {
        didSet {
            passwordField.configure(title: i18n.t(.password), type: .password)
        }
    }
    @IBOutlet weak var errorLabel: UILabel! {
        didSet {
            errorLabel.isHidden = true
            theme.apply(.error, toLabel: errorLabel)
        }
    }
    @IBOutlet weak var legalTextView: UITextView! {
        didSet {
            legalTextView.delegate = self
            legalTextView.text = i18n.t(.byContinuingYouAgree)
            theme.apply(.informational, toTextView: legalTextView)
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
        guard let username = usernameField.text,
              let email = emailField.text,
              let password = passwordField.text else {
            errorLabel.isHidden = false
            errorLabel.text = "Please enter all fields"
            return
        }

        // Validation:
        // - username `/^[a-zA-Z0-9_-]+$/` 3:20

        errorLabel.isHidden = true

        accountProvider?.createAccount(email: email, username: username, password: password, repeatPassword: password, firstName: nil, lastName: nil, subscribe: false)
            .onSuccess { [weak self] (userSession: UserSession) in
                self?.delegate?.didCreateAccount(credentials: Credentials(email: username, password: password), userSession: userSession)
            }
            .onFailure { [weak self] (error) in
                self?.errorLabel.isHidden = false
                self?.errorLabel.text = error.localizedDescription
            }
    }
}

extension CreateAccountViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
}
