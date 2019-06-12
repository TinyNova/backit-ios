/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation
import UIKit

protocol SignInViewControllerDelegate: class {
    /**
     * The user successfully signed in.
     *
     * `Credentials` will be `nil` if the user signed in with a 3rd party provider.
     */
    func didSignIn(credentials: Credentials?, userSession: UserSession)
    
    /**
     * User cancelled the process of logging in.
     */
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
            emailTextField.configure(title: i18n.t(.email), type: .email)
        }
    }
    @IBOutlet private weak var passwordTextField: TextEntryField! {
        didSet {
            passwordTextField.configure(title: i18n.t(.password), type: .password)
        }
    }
    @IBOutlet private weak var errorLabel: UILabel! {
        didSet {
            errorLabel.isHidden = true
            theme.apply(.error, toLabel: errorLabel)
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
    var facebookProvider: FacebookProvider?
    
    weak var delegate: SignInViewControllerDelegate?
    
    let i18n = Localization<Appl10n>()
    let theme: UIThemeApplier<AppTheme> = AppTheme.default
    
    func inject(accountProvider: AccountProvider, facebookProvider: FacebookProvider) {
        self.accountProvider = accountProvider
        self.facebookProvider = facebookProvider
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
                self?.delegate?.didSignIn(credentials: Credentials(email: email, password: password), userSession: userSession)
                self?.dismiss(animated: true, completion: nil)
            }
            .onFailure { [weak errorLabel] error in
                switch error {
                case .thirdParty,
                     .failedToDecode,
                     .generic:
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
        let storyboard = UIStoryboard(name: "LostPasswordViewController", bundle: Bundle(for: SignInViewController.self))
        guard let vc = storyboard.instantiateInitialViewController() as? LostPasswordViewController else {
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapFacebookLogin(_ sender: Any) {
        // TODO: Display a loading indicator
        facebookProvider?.login()
            .mapError { (error: FacebookProviderError) -> AccountProviderError in
                return .thirdParty(error)
            }
            .flatMap { [weak self] (session: FacebookSession) -> Future<UserSession, AccountProviderError> in
                guard let accountProvider = self?.accountProvider else {
                    return Future(error: .generic(WeakReferenceError()))
                }
                return accountProvider.login(with: session)
            }
            .onSuccess { [weak self] (userSession) in
                self?.delegate?.didSignIn(credentials: nil, userSession: userSession)
                self?.dismiss(animated: true, completion: nil)
            }
            .onFailure { [weak self] error in
                self?.errorLabel.text = "\(error)"
            }
    }
    
    @IBAction func didTapGoogleLogin(_ sender: Any) {
        print("login with google")
    }
    
    @IBAction func didTapCreateAccount(_ sender: Any) {
        let storyboard = UIStoryboard(name: "CreateAccountViewController", bundle: Bundle(for: SignInViewController.self))
        guard let vc = storyboard.instantiateInitialViewController() as? CreateAccountViewController else {
            return
        }
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SignInViewController: CreateAccountViewControllerDelegate {
    func didCreateAccount(credentials: Credentials, userSession: UserSession) {
        delegate?.didSignIn(credentials: credentials, userSession: userSession)
        dismiss(animated: true, completion: nil)
    }

    func userCancelled() {

    }
}
