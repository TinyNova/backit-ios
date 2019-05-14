import Foundation
import UIKit

protocol SignInViewControllerDelegate: class {
    func didLogin(userSession: UserSession)
    func userCancelled()
}

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel! {
        didSet {
            errorLabel.isHidden = true
        }
    }
    
    var accountProvider: AccountProvider?
    
    weak var delegate: SignInViewControllerDelegate?
    
    func inject(accountProvider: AccountProvider) {
        self.accountProvider = accountProvider
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelLogin))
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
