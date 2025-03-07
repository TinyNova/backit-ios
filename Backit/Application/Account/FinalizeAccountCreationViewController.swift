/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import BrightFutures
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
    
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = i18n.t(.createAnAccount)
            theme.apply(.loginHeader, toLabel: titleLabel)
        }
    }
    @IBOutlet private weak var usernameField: TextEntryField! {
        didSet {
            usernameField.configure(title: i18n.t(.username), type: .username, returnKeyType: .done)
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
            emailField.configure(title: i18n.t(.email), type: .email, returnKeyType: .done)
            emailField.delegate = self
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

    private var urlSession: URLSession?
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
    
    func inject(urlSession: URLSession, accountProvider: AccountProvider, bannerProvider: BannerProvider, overlay: ProgressOverlayProvider) {
        self.urlSession = urlSession
        self.accountProvider = accountProvider
        self.bannerProvider = bannerProvider
        self.overlay = overlay
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.fromHex(0x130a33)
        emailField.text = profile?.email
    }
    
    @IBAction func didTapCreateAccount(_ sender: Any) {
        guard let signupToken = signupToken else {
            return log.c("Page has not been configured!")
        }
        guard let username = usernameField.text, username.count > 0,
              let email = emailField.text, email.count > 0 else {
            bannerProvider?.present(message: .error(title: nil, message: "Please enter your username and email"), in: self)
            return
        }
        
        overlay?.show()
        accountProvider?.createExternalAccount(email: email, username: username, subscribe: false, signupToken: signupToken)
            .onSuccess { [weak self] (userSession) in
                self?.uploadAvatar()
                    .onComplete { [weak self] _ in
                        self?.overlay?.dismiss()
                        self?.delegate?.didCreateAccount(userSession: userSession)
                    }
            }
            .onFailure { [weak self] (error) in
                self?.overlay?.dismiss()
                self?.bannerProvider?.present(error: error, in: self)
            }
    }
    
    private func uploadAvatar() -> Future<IgnorableValue, Error> {
        guard let urlSession = urlSession,
              let avatarUrl = profile?.avatarUrl else {
            log.i("No profile to upload")
            return Future(value: IgnorableValue())
        }

        log.i("Uploading avatar")
        let promise = Promise<IgnorableValue, Error>()
        
        let task = urlSession.dataTask(with: avatarUrl) { [weak self] (data, response, error) in
            guard error == nil,
                  let imageData = data,
                  let image = UIImage(data: imageData) else {
                log.e("Failed to upload avatar \(String(describing: error)) bytes \(data?.count ?? 0)")
                return promise.success(IgnorableValue())
            }
            
            self?.accountProvider?.uploadAvatar(image: image)
                .onSuccess { _ in
                    log.i("Successfully uploaded the avatar")
                }
                .onFailure { (error) in
                    log.e("Failed to upload the avatar: \(String(describing: error))")
                }
                .onComplete { (result) in
                    promise.success(IgnorableValue())
                }
        }
        task.resume()

        return promise.future
    }
    
    private func usernameResetMessage() {
        usernameState = .reset
        validUsernameLabel.text = "🤖 Awaiting input..."
    }
    
    private func usernameTooShortMessage() {
        usernameState = .tooShort
        validUsernameLabel.text = "💁‍♂️ A username must be between 3 and 20 characters long"
    }
    
    private let q0 = MessageQueue(messages: [
        "❌ Non-binary, non-comforming, username",
        "❌ Not approved by the Council of Usernames"
    ])
    private func usernameTakenMessage() {
        usernameState = .unavailable
        validUsernameLabel.text = q0.next()
    }
    
    private let q1 = MessageQueue(messages: [
        "✅ Username approved by the Council of Usernames",
        "✅ Lrrr accepts your username as 'VALID'!",
        "✅ Username acceptable to the hive mind"
    ])
    private func usernameAvailableMessage() {
        guard usernameState != .available else {
            return
        }
        usernameState = .available
        validUsernameLabel.text = q1.next()
    }
    
    private let q2 = MessageQueue(messages: [
        "🚨 Your username needs a nip and a tuck",
        "🚨 Is that your username or are you just happy to see me?"
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
        guard field == usernameField else {
            return
        }
        
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
                self?.bannerProvider?.present(error: error, in: self)
            }
    }
    
    func didSubmit(field: TextEntryField) {
        didTapCreateAccount(self)
    }
}
