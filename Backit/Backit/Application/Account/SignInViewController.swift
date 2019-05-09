import Foundation
import UIKit

protocol SignInViewControllerDelegate: class {
    func didLogin(userSession: UserSession)
    func userCancelled()
}

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
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
            return print("Please enter your username and password")
        }
        
        accountProvider?.login(email: email, password: password).onSuccess { [weak delegate] (userSession) in
            delegate?.didLogin(userSession: userSession)
        }
    }
    
    @objc private func cancelLogin(_ sender: Any) {
        delegate?.userCancelled()
    }
}
