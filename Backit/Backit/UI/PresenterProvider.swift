/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

protocol PresenterProvider {
    /**
     * The `UIViewController` that should be used when presenting view controllers.
     *
     * This should only _ever_ be used for 3rd party frameworks which do not allow you to present their view controllers directly.
     */
    var viewController: UIViewController? { get }
    
    func present(_ viewController: UIViewController, completion: (() -> Void)?)
    func dismiss(_ viewController: UIViewController, completion: (() -> Void)?)
    func push(_ viewController: UIViewController)
}
