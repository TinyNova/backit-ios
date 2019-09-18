import Foundation
import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchFieldBackgroundView: UIView! {
        didSet {
            searchFieldBackgroundView.backgroundColor = UIColor.bk.purple
        }
    }
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            cancelButton.setTitle("Cancel", for: .normal)
            let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCancel(_:)))
            cancelButton.setTitleColor(UIColor.bk.white, for: .normal)
            cancelButton.gestureRecognizers = [tap]
            cancelButton.isUserInteractionEnabled = true
        }
    }
    @IBOutlet private weak var searchIconView: CenteredImageView! {
        didSet {
            searchIconView.configure(image: UIImage(named: "search")?.sd_tintedImage(with: UIColor.bk.white), size: 30.0)
            searchIconView.hero.id = "App.Search"
        }
    }
    @IBOutlet private weak var searchTextField: UITextField! {
        didSet {
            theme.apply(.search, toTextField: searchTextField)
        }
    }
    
    private var theme: UIThemeApplier<AppTheme> = AppTheme.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: Animate the search icon to the left
        // TODO: Animate the cancel button from the button
        // TODO: Allow the content to be shown through the VC
        
        searchTextField.becomeFirstResponder()
        
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else {
            return
        }
        
        statusBar.backgroundColor = UIColor.bk.purple
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc private func didTapCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
