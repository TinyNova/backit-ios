/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

class AppPresenterProvider: PresenterProvider {
    
    func present(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
        guard let topViewController = UIApplication.topViewController() else {
            return
        }
        
        topViewController.present(viewController, animated: true, completion: completion)
    }
}

private extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
