/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

extension UIFont {

    /**
     Display all font names in the console.

     */
    static func displayAllAvailableFonts() {
        let familyNames = UIFont.familyNames
        familyNames.forEach { (familyName) in
            let fontNames = UIFont.fontNames(forFamilyName: familyName)
            fontNames.forEach { (fontName) in
                print("Font name: \(fontName)")
            }
        }
    }
}
