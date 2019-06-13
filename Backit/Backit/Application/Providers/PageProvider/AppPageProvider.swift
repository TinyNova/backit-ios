/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

class AppPageProvider: PageProvider {
    
    func finalizeAccountCreation() -> FinalizeAccountCreationViewController {
        let storyboard = UIStoryboard(name: "FinalizeAccountCreationViewController", bundle: Bundle(for: FinalizeAccountCreationViewController.self))
        guard let vc = storyboard.instantiateInitialViewController() as? FinalizeAccountCreationViewController else {
            fatalError("Failed to inflate FinalizeAccountCreationViewController")
        }

        return vc
    }
}
