/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import BrightFutures
import UIKit

class ProjectDetailsViewController: UIViewController {
    
    private var future: Future<Project, ProjectProviderError>?
    
    func configure(with future: Future<Project, ProjectProviderError>) {
        self.future = future
    }
}
