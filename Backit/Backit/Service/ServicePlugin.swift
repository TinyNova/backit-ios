/**
 Provides the ability to modify a `URLRequest` before the request is made.
 
 License: MIT
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Foundation
import BrightFutures

protocol ServicePlugin {
    var key: ServicePluginKey { get }
    
    func willSendRequest(_ request: URLRequest) -> Future<URLRequest, Error>
    func didSendRequest(_ request: URLRequest)
    func didReceiveResponse(_ response: ServiceResult) -> ServiceResult
}
