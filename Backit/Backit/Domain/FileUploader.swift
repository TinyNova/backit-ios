import BrightFutures
import Foundation
import UIKit

enum FileUploaderError: Error {
    case unknown(Error)
}

protocol FileUploader {
    func upload(image: UIImage) -> Future<NoResult, FileUploaderError>
}
