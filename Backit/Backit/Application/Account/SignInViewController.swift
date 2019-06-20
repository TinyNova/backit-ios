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
    
    weak var delegate: SignInViewControllerDelegate?
    
    private var accountProvider: AccountProvider?
    private var bannerProvider: BannerProvider?
    private var overlay: ProgressOverlayProvider?
    private var externalProvider: ExternalSignInProvider?
    private var facebookProvider: FacebookProvider?
    private var googleProvider: GoogleProvider?
    
    private let i18n = Localization<Appl10n>()
    private let theme: UIThemeApplier<AppTheme> = AppTheme.default
    
    func inject(accountProvider: AccountProvider, bannerProvider: BannerProvider, overlay: ProgressOverlayProvider, externalProvider: ExternalSignInProvider, facebookProvider: FacebookProvider, googleProvider: GoogleProvider) {
        self.accountProvider = accountProvider
        self.bannerProvider = bannerProvider
        self.overlay = overlay
        self.externalProvider = externalProvider
        self.facebookProvider = facebookProvider
        self.googleProvider = googleProvider
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
            bannerProvider?.present(type: .error, title: nil, message: "Please enter your email and password")
            return
        }

        overlay?.show(in: self)
        accountProvider?.login(email: email, password: password)
            .onSuccess { [weak self] (userSession) in
                self?.delegate?.didSignIn(credentials: Credentials(email: email, password: password), userSession: userSession)
                self?.dismiss(animated: true, completion: nil)
            }
            .onFailure { [weak self] error in
                self?.bannerProvider?.present(error: error)
            }
            .onComplete { [weak self] _ in
                self?.overlay?.dismiss()
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
        overlay?.show(in: self)
        facebookProvider?.login()
            .mapError { (error: FacebookProviderError) -> Error in
                return error
            }
            .flatMap { [weak self] (token: FacebookAccessToken) -> Future<UserSession, Error> in
                guard let externalProvider = self?.externalProvider else {
                    return Future(error: WeakReferenceError())
                }
                return externalProvider.login(with: token, provider: .facebook)
                    .mapError { (error) -> Error in
                        // TODO: if the reason for the failure is because we failed to login (bad network connection) display a banner and allow the user to try again.
                        return error
                    }
            }
            .onSuccess { [weak self] (userSession) in
                self?.delegate?.didSignIn(credentials: nil, userSession: userSession)
                self?.dismiss(animated: true, completion: nil)
            }
            .onFailure { [weak self] error in
                self?.bannerProvider?.present(error: error)
            }
            .onComplete { [weak self] _ in
                self?.overlay?.dismiss()
            }
    }
    
    @IBAction func didTapGoogleLogin(_ sender: Any) {
        overlay?.show(in: self)
        googleProvider?.login()
            .mapError { (error: GoogleProviderError) -> Error in
                return error
            }
            .flatMap { [weak self] (token: GoogleAuthenticationToken) -> Future<UserSession, Error> in
                guard let externalProvider = self?.externalProvider else {
                    return Future(error: WeakReferenceError())
                }
                return externalProvider.login(with: token, provider: .google)
                    .mapError { (error) -> Error in
                        // TODO: if the reason for the failure is because we failed to login (bad network connection) display a banner and allow the user to try again.
                        return error
                }
            }
            .onSuccess { [weak self] (userSession) in
                self?.delegate?.didSignIn(credentials: nil, userSession: userSession)
                self?.dismiss(animated: true, completion: nil)
            }
            .onFailure { [weak self] error in
                self?.bannerProvider?.present(error: error)
            }
            .onComplete { [weak self] _ in
                self?.overlay?.dismiss()
            }
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
