/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

import BackitApp

func applicationClassName() -> String? {
    if NSClassFromString("XCTestCase") == nil {
        return NSStringFromClass(Application.self)
    }
    else {
        return NSStringFromClass(TestApplication.self)
    }
}

_ = UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, applicationClassName(), nil)
