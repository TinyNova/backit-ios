import Foundation
import UIKit
import WebKit

class ProjectDescriptionViewController: UIViewController {
    
    @IBOutlet private weak var webView: WKWebView!
    
    private var htmlString: String?
    
    public func configureWith(htmlString: String) {
        let removeNewlines = htmlString.replacingOccurrences(of: "\\n", with: "<br/>")
        self.htmlString = """
        <html>
        <head>
        <title>Project Description</title>
        <style>
        body {
          color: #020621;
          font: 20pt "Helvetica Neue", Helvetica, Arial, "Liberation Sans", FreeSans, sans-serif;
          -webkit-font-smoothing: antialiased;
          margin: auto;
          padding: 10pt;
          text-align: center;
        
        }
        </style>
        </head>
        <body>
        \(removeNewlines)
        </body>
        </html>
        """
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
