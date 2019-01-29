/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

extension UIImage {
    
    /**
     Generate a new image that fits within the defined width while preserving aspect ration.
     
     - parameter width: The new width of the image
     - returns: A new `UIImage`
     */
    func fittedImage(to width: CGFloat) -> UIImage? {
        let oldWidth = self.size.width
        let scaleFactor = width / oldWidth
        
        let newHeight = self.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        let size = CGSize(width: newWidth, height: newHeight)
        // NOTE: Make sure this is using the more efficient version of drawing images.
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        draw(in: CGRect(x:0, y:0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
