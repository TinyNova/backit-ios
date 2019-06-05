import BrightFutures
import Foundation
import UIKit

class AmazonService: FileUploader {
    
    func upload(image: UIImage) -> Future<IgnorableValue, FileUploaderError> {
        return Future(error: .unknown(GenericError()))
    }
}
