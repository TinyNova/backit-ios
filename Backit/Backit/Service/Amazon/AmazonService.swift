/**
 * Provides Amazon services.
 *
 * Valid ACL values: private | public-read | public-read-write | aws-exec-read | authenticated-read | bucket-owner-read | bucket-owner-full-control
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation
import UIKit

struct S3UploadFile {
    // The `filename` should _not_ contain the file extension. The service will add it as it determines how to encode the file (JPEG | PNG | etc.).
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
    case failedToCreateRequest
    case failedToConvertImageToJpeg
    case failedToUploadFile(Error)
}

class AmazonService {
    
    let urlSession: URLSession
    
    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
    
    func upload(file: S3UploadFile, image: UIImage) -> Future<IgnorableValue, AmazonServiceError> {
        guard let url = URL(string: "https://\(file.bucket).s3.amazonaws.com/") else {
            return Future(error: .failedToCreateRequest)
        }
        guard let data = image.jpegData(compressionQuality: 1.0) else {
            return Future(error: .failedToConvertImageToJpeg)
        }
        
        let promise = Promise<IgnorableValue, AmazonServiceError>()

        let boundary = generateBoundary()
        let httpBody = generateHTTPBody(for: file, data: data, boundary: boundary)
        
        let filename = "\(file.filename).jpg"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "multipart/form-data; boundary=\"\(boundary)\"",
            // TODO: Potentially add a custom User-Agent string so that we can track downloads by platform and app version.
            "X-Filename": escapedValue(filename),
            "Content-Length": "\(httpBody.count)",
        ]
        request.httpBody = httpBody
        print("INFO: Making request to upload file: \(filename)")
        urlSession.dataTask(with: request) { (data, response, error) in
            if let error = error {
                promise.failure(.failedToUploadFile(error))
                return print("ERR: \(error)")
            }
            
            promise.success(IgnorableValue())
            print("Successfully uploaded file: \(filename)")
        }
        
        return promise.future
    }
    
    private func escapedValue(_ value: String) -> String {
        var charSet = CharacterSet.alphanumerics
        charSet.insert(charactersIn: "-_.!~*'()")
        return value.addingPercentEncoding(withAllowedCharacters: charSet)!
    }
    
    private func generateHTTPBody(for file: S3UploadFile, data: Data, boundary: String) -> Data {
        var httpBody = Data()
        
        func append(_ string: String) {
            httpBody.append(string.data(using: .utf8, allowLossyConversion: false) ?? Data())
        }
        
        func appendField(name: String, value: String) {
            append("--\(boundary)\r\n")
            append("Content-Type: text/plain; charset=utf-8\r\n")
            append("Content-Disposition: form-data; name=\(name)\r\n\r\n")
            append(value)
        }
        
        // Fields
        appendField(name: "acl", value: file.acl)
        appendField(name: "AWSAccessKeyId", value: file.awsKey)
        appendField(name: "key", value: file.key)
        appendField(name: "policy", value: file.policy)
        appendField(name: "signature", value: file.signature)
        
        // Image
        append("Content-Type: image/jpeg\r\n")
        append("Content-Disposition: form-data; name=file\r\n\r\n")
        httpBody.append(data)
        append("\r\n--\(boundary)--\r\n")
        
        return httpBody
    }
    
    private func generateBoundary() -> String {
        return UUID().uuidString
    }
}
