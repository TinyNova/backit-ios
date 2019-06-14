/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

protocol FinalizeAccountCreationViewControllerDelegate: class {
    func didCreateAccount(userSession: UserSession)
}

class FinalizeAccountCreationViewController: UIViewController {
    
    @IBOutlet weak var usernameField: TextEntryField! {
        didSet {
            usernameField.configure(title: i18n.t(.username), type: .username)
        }
    }
    @IBOutlet weak var validUsernameImageView: UIImageView!
    @IBOutlet weak var validUsernameLabel: UILabel! {
        didSet {
            validUsernameLabel.numberOfLines = 0
            validUsernameLabel.text = "🤖 Awaiting input..."
            // 🤖 Awaiting input...
            // 💁‍♂️ A username must be at least 3 characters long
            // ❌ seat's taken
            // ❌ taken
            // ✅ You can sit with me
            // ✅ I do declare, Mr. Vandergelder! That username suits you just fine!
            // 🚨 Why? Why?! The username is too long!
            // 🚨 Dammit, Scotty! The username is just... too... damn... long
        }
    }
    @IBOutlet weak var emailField: TextEntryField! {
        didSet {
            emailField.configure(title: i18n.t(.email), type: .email)
        }
    }
    @IBOutlet weak var informationalTextView: UITextView! {
        didSet {
            informationalTextView.text = i18n.t(.finalizeCreatingYourAccount)
        }
    }
    @IBOutlet weak var createAccountButton: PrimaryButton! {
        didSet {
            createAccountButton.title = i18n.t(.createAccount)
        }
    }
    
    weak var delegate: FinalizeAccountCreationViewControllerDelegate?
    
    let i18n = Localization<Appl10n>()
    let theme: UIThemeApplier<AppTheme> = AppTheme.default

    var accountProvider: AccountProvider?
    var profile: ExternalUserProfile?
    
    func configure(with profile: ExternalUserProfile) {
        self.profile = profile
        emailField.text = profile.email
    }
    
    func inject(accountProvider: AccountProvider) {
        self.accountProvider = accountProvider
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = i18n.t(.createAccount)
    }
    
    @IBAction func didTapCreateAccount(_ sender: Any) {
        guard let username = usernameField.text, username.count > 0,
              let email = emailField.text, email.count > 0 else {
            print("Please enter your username and email.")
            return
        }
        
        accountProvider?.createExternalAccount(email: email, username: username)
            .onSuccess { [weak self] (userSession) in
                self?.delegate?.didCreateAccount(userSession: userSession)
            }
            .onFailure { (error) in
                print("Failed to create account: \(error)")
            }
    }
}
