/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

class AppPresenterProvider: PresenterProvider {
    
    var viewController: UIViewController? {
        return UIApplication.topViewController()
    }
    
    func present(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
        guard let topViewController = UIApplication.topViewController() else {
            return log.w("Failed to present \(viewController) on the top UIViewController")
        }
        
        topViewController.present(viewController, animated: true, completion: completion)
    }
    
    func dismiss(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
        guard let topViewController = viewController.presentingViewController else {
            return
        }

        topViewController.dismiss(animated: true, completion: completion)
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
