import Foundation
import UIKit

protocol SignInViewControllerDelegate: class {
    func didLogin(userSession: UserSession)
    func userCancelled()
}

class SignInViewController: UIViewController {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var errorLabel: UILabel! {
        didSet {
            errorLabel.isHidden = true
        }
    }
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var forgotPasswordButton: UIButton!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var loginWithFacebookButton: UIButton!
    @IBOutlet private weak var loginWithGoogleButton: UIButton!
    @IBOutlet private weak var createAccountButton: UIButton!
    
    var accountProvider: AccountProvider?
    
    weak var delegate: SignInViewControllerDelegate?
    
    func inject(accountProvider: AccountProvider) {
        self.accountProvider = accountProvider
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.fromHex(0x130a33)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelLogin))
    }
    
    @IBAction func didTapLogin(_ sender: Any) {
        guard let email = emailTextField.text,
            let password = passwordTextField.text else {
            errorLabel.isHidden = false
            errorLabel.text = "Please enter your email and password."
            return
        }
        
        accountProvider?.login(email: email, password: password)
            .onSuccess { [weak delegate] (userSession) in
                delegate?.didLogin(userSession: userSession)
            }
            .onFailure { [weak errorLabel] error in
                errorLabel?.isHidden = false
                errorLabel?.text = "\(error)"
            }
    }
    
    @objc private func cancelLogin(_ sender: Any) {
        delegate?.userCancelled()
    }
}
