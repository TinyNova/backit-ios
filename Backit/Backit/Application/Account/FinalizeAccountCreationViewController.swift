/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

protocol FinalizeAccountCreationViewControllerDelegate: class {
    func didCreateAccount(userSession: UserSession)
}

private enum UsernameState: Int {
    case initial
    case reset
    case available
    case unavailable
    case tooShort
    case tooLong
}

private class MessageQueue {
    private let messages: [String]
    
    private var value: Int = -1
    private var max: Int = 0
    
    init(messages: [String]) {
        self.messages = messages
        self.max = messages.count
    }
    
    var current: String {
        return messages[value]
    }
    
    func next() -> String {
        guard messages.count > 0 else {
            log.w("`MessageQueue.messages` has no messages")
            return ""
        }
        
        value += 1
        if value >= max {
            value = 0
        }
        return messages[value]
    }
}


class FinalizeAccountCreationViewController: UIViewController {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var usernameField: TextEntryField! {
        didSet {
            usernameField.configure(title: i18n.t(.username), type: .username)
            usernameField.delegate = self
        }
    }
    @IBOutlet private weak var validUsernameLabel: UILabel! {
        didSet {
            theme.apply(.info, toLabel: validUsernameLabel)
            usernameResetMessage()
        }
    }
    @IBOutlet private weak var emailField: TextEntryField! {
        didSet {
            emailField.configure(title: i18n.t(.email), type: .email)
        }
    }
    @IBOutlet private weak var informationalTextView: UITextView! {
        didSet {
            theme.apply(.informational, toTextView: informationalTextView)
            informationalTextView.text = i18n.t(.finalizeCreatingYourAccount)
        }
    }
    @IBOutlet private weak var createAccountButton: PrimaryButton! {
        didSet {
            createAccountButton.title = i18n.t(.createAccount)
        }
    }
    
    weak var delegate: FinalizeAccountCreationViewControllerDelegate?
    
    private var usernameObserver: NSKeyValueObservation?
    
    private let i18n = Localization<Appl10n>()
    private let theme: UIThemeApplier<AppTheme> = AppTheme.default

    private var accountProvider: AccountProvider?
    private var bannerProvider: BannerProvider?
    private var overlay: ProgressOverlayProvider?
    
    private var signupToken: String?
    private var profile: ExternalUserProfile?
    private var usernameState: UsernameState = .initial
    private var requestCounter: Int = 0
    
    func configure(signupToken: String, profile: ExternalUserProfile) {
        self.signupToken = signupToken
        self.profile = profile
    }
    
    func inject(accountProvider: AccountProvider, bannerProvider: BannerProvider, overlay: ProgressOverlayProvider) {
        self.accountProvider = accountProvider
        self.bannerProvider = bannerProvider
        self.overlay = overlay
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.fromHex(0x130a33)
        title = i18n.t(.createAccount)
        emailField.text = profile?.email
    }
    
    @IBAction func didTapCreateAccount(_ sender: Any) {
        guard let signupToken = signupToken else {
            return log.c("Page has not been configured!")
        }
        guard let username = usernameField.text, username.count > 0,
              let email = emailField.text, email.count > 0 else {
            bannerProvider?.present(type: .error, title: nil, message: "Please enter your username and email")
            return
        }
        
        overlay?.show(in: self)
        accountProvider?.createExternalAccount(email: email, username: username, subscribe: false, signupToken: signupToken)
            .onSuccess { [weak self] (userSession) in
                self?.delegate?.didCreateAccount(userSession: userSession)
            }
            .onFailure { [weak self] (error) in
                self?.bannerProvider?.present(error: error)
            }
            .onComplete { [weak self] _ in
                self?.overlay?.dismiss()
            }
    }
    
    private func usernameResetMessage() {
        usernameState = .reset
        validUsernameLabel.text = "🤖 Awaiting input..."
    }
    
    private func usernameTooShortMessage() {
        usernameState = .tooShort
        validUsernameLabel.text = "💁‍♂️ A username must be at least 3 characters long"
    }
    
    private let q0 = MessageQueue(messages: [
        "❌ seat's taken",
        "❌ taken"
    ])
    private func usernameTakenMessage() {
        usernameState = .unavailable
        validUsernameLabel.text = q0.next()
    }
    
    private let q1 = MessageQueue(messages: [
        "✅ You can sit with me",
        "✅ I do declare, Mr. Vandergelder! That username suits you just fine!"
    ])
    private func usernameAvailableMessage() {
        guard usernameState != .available else {
            return
        }
        usernameState = .available
        validUsernameLabel.text = q1.next()
    }
    
    private let q2 = MessageQueue(messages: [
        "🚨 Why? Why?! The username is too long!",
        "🚨 Dammit, Scotty! The username is just... too... damn... long"
    ])
    private func usernameTooLongMessage() {
        guard usernameState != .tooLong else {
            return
        }
        usernameState = .tooLong
        validUsernameLabel.text = q2.next()
    }
}

extension FinalizeAccountCreationViewController: TextEntryFieldDelegate {
    func didChangeText(field: TextEntryField, text: String?) {
        // FIXME: This method could cause overflow or reset
        requestCounter += 1

        guard let text = text else {
            return usernameResetMessage()
        }
        guard text.count > 2 else {
            return usernameTooShortMessage()
        }
        guard text.count < 21 else {
            return usernameTooLongMessage()
        }
        
        let ctr = requestCounter
        
        // TODO: Debounce
        accountProvider?.usernameAvailable(username: text)
            .onSuccess { [weak self] (available) in
                guard ctr == self?.requestCounter ?? 0 else {
                    return
                }
                
                if available {
                    self?.usernameAvailableMessage()
                }
                else {
                    self?.usernameTakenMessage()
                }
            }
            .onFailure { [weak self] (error) in
                self?.bannerProvider?.present(error: error)
            }
    }
}
