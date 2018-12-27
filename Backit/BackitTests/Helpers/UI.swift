/**
 
 @copyright 2017 Upstart Illustration LLC. All rights reserved.
 */

import Foundation
import UIKit

func createViewController<T: AnyObject>(_ type: T.Type, storyboardName: String, storyboardIdentifier: String) -> T {
    let bundle = Bundle(for: T.self)
    let storyboard = UIStoryboard(name: storyboardName, bundle: bundle)
    return storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as! T
}

/**
 Prepares the UIViewController to be tested by making it the root view controller.
 
 - parameter viewController: The UIViewController to test.
 */
internal func testViewController(_ viewController: UIViewController) {
    UIApplication.shared.keyWindow?.layer.speed = 100
    for view in (UIApplication.shared.keyWindow?.subviews)! {
        view.removeFromSuperview()
    }
    UIApplication.shared.keyWindow?.rootViewController = viewController
//    self.tester().waitForAnimationsToFinish()
    crankRunLoop()
}
