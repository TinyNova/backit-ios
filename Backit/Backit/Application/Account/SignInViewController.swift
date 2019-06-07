/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

protocol SignInViewControllerDelegate: class {
    func didSignIn(credentials: Credentials, userSession: UserSession)
    func userCancelled()
}

class SignInViewController: UIViewController {
    
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = i18n.t(.loginToBackit)
            theme.apply(.loginHeader, toLabel: titleLabel)
        }
    }
    
    @IBOutlet private weak var emailTextField: TextEntryField! {
        didSet {
            emailTextField.configure(title: "Username", isSecure: false)
        }
    }
    @IBOutlet private weak var passwordTextField: TextEntryField! {
        didSet {
            passwordTextField.configure(title: "Password", isSecure: true)
        }
    }
    @IBOutlet private weak var errorLabel: UILabel! {
        didSet {
            errorLabel.isHidden = true
        }
    }

    @IBOutlet private weak var loginButton: PrimaryButton! {
        didSet {
            loginButton.title = i18n.t(.continue).uppercased()
        }
    }
    
    @IBOutlet private weak var forgotPasswordButton: TextButton! {
        didSet {
            forgotPasswordButton.title = i18n.t(.forgotYourPassword)
        }
    }
    
    @IBOutlet private weak var separatorView: UIView! {
        didSet {
            separatorView.backgroundColor = UIColor.fromHex(0x5f637b)
        }
    }
    
    @IBOutlet private weak var loginWithFacebookButton: SecondaryButton! {
        didSet {
            loginWithFacebookButton.title = i18n.t(.loginWithFacebook)
        }
    }
    
    @IBOutlet private weak var loginWithGoogleButton: SecondaryButton! {
        didSet {
            loginWithGoogleButton.title = i18n.t(.loginWithGoogle)
        }
    }
    
    @IBOutlet private weak var createAccountButton: UnderlineButton! {
        didSet {
            createAccountButton.title = i18n.t(.signUpForAccount)
        }
    }
    
    var accountProvider: AccountProvider?
    
    weak var delegate: SignInViewControllerDelegate?
    
    let i18n = Localization<Appl10n>()
    let theme: UIThemeApplier<AppTheme> = AppTheme.default
    
    func inject(accountProvider: AccountProvider) {
        self.accountProvider = accountProvider
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.fromHex(0x130a33)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelLogin))
    }
    
    @objc private func cancelLogin(_ sender: Any) {
        delegate?.userCancelled()
    }

    @IBAction func didTapLogin(_ sender: Any) {
        guard let email = emailTextField.text, email.count > 0,
            let password = passwordTextField.text, password.count > 0 else {
                errorLabel.isHidden = false
                errorLabel.text = "Please enter your email and password."
                return
        }

        accountProvider?.login(email: email, password: password)
            .onSuccess { [weak self] (userSession) in
                self?.delegate?.didSignIn(credentials: Credentials(username: email, password: password), userSession: userSession)
                self?.dismiss(animated: true, completion: nil)
            }
            .onFailure { [weak errorLabel] error in
                switch error {
                case .unknown,
                     .failedToDecode,
                     .service:
                    errorLabel?.text = "Something funky is going on! Don't worry, we're on it!"
                case .validation(let fields):
                    let errors: [String] = fields.map { (fieldErrors) -> String in
                        return "\(fieldErrors.key): \(fieldErrors.value.joined(separator: ", "))"
                    }
                    errorLabel?.text = errors.joined(separator: "\n")
                }
                errorLabel?.isHidden = false
            }
    }

    @IBAction func didTapForgotPassword(_ sender: Any) {
        print("forgot password")
    }
    
    @IBAction func didTapFacebookLogin(_ sender: Any) {
        print("login to facebook")
    }
    
    @IBAction func didTapGoogleLogin(_ sender: Any) {
        print("login with google")
    }
    
    @IBAction func didTapCreateAccount(_ sender: Any) {
        print("create account")
    }
}
