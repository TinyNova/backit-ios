import BrightFutures
import Foundation
import UIKit

class AmazonService: FileUploader {
    
    func upload(image: UIImage) -> Future<NoResult, FileUploaderError> {
        return Future(error: .unknown(GenericError()))
    }
}
