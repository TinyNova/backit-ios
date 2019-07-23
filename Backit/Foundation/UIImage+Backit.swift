/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Accelerate
import Foundation
import UIKit

extension UIImage {
    
    /**
     Generate a new image that fits within the defined width while preserving aspect ration.
     
     This can be used for both vector and non-vector images.
     For best results for non-vector images, please use `resizedImage`.
     
     - parameter width: The new width of the image
     - returns: A new `UIImage`
     */
    func fittedImage(to width: CGFloat) -> UIImage? {
        let size = proportionalScaledSize(using: width)
        // NOTE: Make sure this is using the more efficient version of drawing images.
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /**
     Given a `width` constraint, return a proportional `CGSize`.
     
     - parameter width: width constraint
     - returns: `CGSize` with proportional height
     */
    func proportionalScaledSize(using width: CGFloat) -> CGSize {
        let oldWidth = self.size.width
        let scaleFactor = width / oldWidth
        
        let oldHeight = self.size.height
        let newHeight = oldHeight * scaleFactor
        
        return CGSize(width: width, height: newHeight)
    }
    
    /**
     Returns a resized image as the provided size using vector image processing.
     
     This should be used for non-vector images.
     
     Using the Lanczos method, the results of the resized image _should_ be much more crisp than using standard resizing methods.
     
     - parameter size: size constraint
     - returns: a new image with `size`
     */
    func resizedImage(using size: CGSize) -> UIImage? {
        // Source buffer
        let cgImage = self.cgImage!
        var format = vImage_CGImageFormat(
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            colorSpace: nil,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),
            version: 0,
            decode: nil,
            renderingIntent: CGColorRenderingIntent.defaultIntent
        )
        var sourceBuffer = vImage_Buffer()
        defer {
            free(sourceBuffer.data)
        }
        
        var error = vImageBuffer_InitWithCGImage(&sourceBuffer, &format, nil, cgImage, numericCast(kvImageNoFlags))
        guard error == kvImageNoError else {
            return nil
        }
        
        // Destination buffer
        let scale = self.scale
        let destWidth = Int(size.width)
        let destHeight = Int(size.height)
        let bytesPerPixel = self.cgImage!.bitsPerPixel / 8
        let destBytesPerRow = destWidth * bytesPerPixel
        let destData = UnsafeMutablePointer<UInt8>.allocate(capacity: destHeight * destBytesPerRow)
        defer { // This crashes
//            destData.deallocate()
        }
        
        var destBuffer = vImage_Buffer(data: destData, height: vImagePixelCount(destHeight), width: vImagePixelCount(destWidth), rowBytes: destBytesPerRow)
        defer { // NOTE: This needed?
            free(destBuffer.data)
        }
        
        // Scale the image
        error = vImageScale_ARGB8888(&sourceBuffer, &destBuffer, nil, numericCast(kvImageHighQualityResampling))
        guard error == kvImageNoError else {
            return nil
        }
        
        // Create CGImage
        var destCGImage = vImageCreateCGImageFromBuffer(&destBuffer, &format, nil, nil, numericCast(kvImageNoFlags), &error)?.takeRetainedValue()
        guard error == kvImageNoError else {
            return nil
        }
        
        // Create UIImage
        let resizedImage = destCGImage.flatMap {
            return UIImage(cgImage: $0, scale: 0.0, orientation: self.imageOrientation)
        }
        destCGImage = nil
        return resizedImage
    }
}
