/**
 * Provides an overlay which prevents user input while an operation is taking place.
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

protocol ProgressOverlayProvider {
    
    /**
     * Display a fullscreen progress overlay.
     */
    func show()
    
    /**
     * Show the progress overlay on top of the `viewController`.
     */
    func show(in viewController: UIViewController)
    
    func dismiss()
}
