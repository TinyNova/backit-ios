/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

protocol PresenterProvider {
    func present(_ viewController: UIViewController, completion: (() -> Void)?)
    func dismiss(_ viewController: UIViewController, completion: (() -> Void)?)
}
