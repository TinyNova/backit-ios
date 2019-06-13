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
    
    @IBOutlet weak var usernameField: TextEntryField!
    
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
    
    @IBOutlet weak var emailField: TextEntryField!
    
    @IBOutlet weak var informationalTextView: UITextView! {
        didSet {
            informationalTextView.text = i18n.t(.finalizeCreatingYourAccount)
        }
    }
    
    @IBOutlet weak var createAccountButton: PrimaryButton!
    
    weak var delegate: FinalizeAccountCreationViewControllerDelegate?
    
    let i18n = Localization<Appl10n>()
    let theme: UIThemeApplier<AppTheme> = AppTheme.default

    func configure(with: ExternalUserProfile) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = i18n.t(.createAccount)
    }
    
    @IBAction func didTapCreateAccount(_ sender: Any) {
    }
    
}
