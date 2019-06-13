/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

protocol FinalizeAccountCreationViewControllerDelegate: class {
    func didCreateAccount(userSession: UserSession)
}

class FinalizeAccountCreationViewController: UIViewController {
    
    weak var delegate: FinalizeAccountCreationViewControllerDelegate?
    
    func configure(with: ExternalUserProfile) {
        
    }
}
