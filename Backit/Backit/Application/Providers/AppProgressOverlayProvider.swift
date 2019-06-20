/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

class AppProgressOverlayProvider: ProgressOverlayProvider {
    func show(in viewController: UIViewController) {
        log.i("show overlay")
    }
    
    func dismiss() {
        log.i("hide overlay")
    }
}
