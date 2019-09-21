import Foundation
import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
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

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done {
            // Do final search if one hasn't been done yet.
            return true
        }
        return false
    }
}

class GroupTypeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
}

class TinyProjectTableViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var progressBarView: UIProgressView!
    @IBOutlet weak var daysLeftLabel: UILabel!
    @IBOutlet weak var earlyBirdRewardsLabel: UILabel!
}

extension SearchViewController: UITableViewDelegate {
    
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
