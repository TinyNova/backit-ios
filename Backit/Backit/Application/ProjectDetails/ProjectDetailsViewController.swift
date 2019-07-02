/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import BrightFutures
import UIKit
import WebKit

class ProjectDetailsViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    private var context: Any?
    
    func configure(with context: Any?) {
        self.context = context
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let project = context as? Project,
              let url = project.internalUrl else {
            return log.e("Could not get project URL at backit.com")
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
