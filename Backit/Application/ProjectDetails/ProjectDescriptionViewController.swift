import Foundation
import UIKit
import WebKit

class ProjectDescriptionViewController: UIViewController {
    
    @IBOutlet private weak var webView: WKWebView!
    
    private var htmlString: String?
    
    public func configureWith(htmlString: String) {
        self.htmlString = htmlString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDoneButton))
        navigationItem.rightBarButtonItem = doneButton
        
        if let html = htmlString {
            webView.loadHTMLString(html, baseURL: nil)
        }
    }
    
    @objc private func didTapDoneButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
