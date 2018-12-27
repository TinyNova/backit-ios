/**
 *
 * Copyright © 2018 Backit. All rights reserved.
 */

import BrightFutures
import Foundation
import Quick
import Nimble
import Spry
import Spry_Nimble

@testable import Backit

class HomepageViewControllerSpec: QuickSpec {
    override func spec() {
        
        describe("given a HomepageViewController") {
            var subject: HomepageViewController!
            
            beforeEach {
                subject = createViewController(HomepageViewController.self, storyboardName: "Main", storyboardIdentifier: "Homepage")
                testViewController(subject)
            }
        }
        
    }
}
