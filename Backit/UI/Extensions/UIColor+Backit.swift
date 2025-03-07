/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

extension UIColor {
    
    static func fromHex(_ hex: UInt32) -> UIColor {
        let r: CGFloat = CGFloat((hex >> UInt32(16)) & UInt32(0xFF))
        let g: CGFloat = CGFloat((hex >> UInt32(8)) & UInt32(0xFF))
        let b: CGFloat = CGFloat((hex) & UInt32(0xFF))
        
        return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha:1.0)
    }
}

class Colors {
    
    var purple: UIColor {
        return UIColor.fromHex(0x130a33)
    }
    
    var white: UIColor {
        return UIColor.fromHex(0xffffff)
    }
    
    var black: UIColor {
        return UIColor.fromHex(0x000000)
    }
}
private let colors = Colors()

extension UIColor {
    
    static var bk: Colors {
        return colors
    }
}
