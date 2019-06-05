import BrightFutures
import Foundation
import AWSS3
import UIKit

struct S3UploadFile {
    let filename: String
    let bucket: String
    let acl: String
    let awsKey: String
    let key: String
    let policy: String
    let signature: String
}

enum AmazonServiceError: Error {
    case unknown(Error)
}

class AmazonService {
    
    func upload(file: S3UploadFile, image: UIImage) -> Future<IgnorableValue, AmazonServiceError> {
        return Future(error: .unknown(GenericError()))
    }
}
