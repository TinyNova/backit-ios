/**
 * Replaces host of all requests to a specified IP address.
 *
 * This was created as a proof of concept to change all QA hosts to a different host. The idea was abandoned in favor of adding `.dev` configurations to all `ServiceEndpoint`s.
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import BrightFutures

struct HostRule {
    let subject: String
    
    fileprivate let host: String
    fileprivate let port: Int
    
    init(subject: String, replacement: String) {
        self.subject = subject
        
        let parts = replacement.split(separator: ":")
        self.host = String(parts[0])
        self.port = Int(String(parts[1])) ?? 80
    }
}

class HostReplacerServicePlugin: ServicePlugin {
    
    var key: ServicePluginKey = .alwaysUse
    
    private let rules: [HostRule]
    
    init(rules: [HostRule]) {
        self.rules = rules
    }
    
    func willSendRequest(_ request: URLRequest) -> Future<URLRequest, ServicePluginError> {
        guard let url = request.url else {
            log.w("Failed to derive URL from `URLRequest.url`")
            return Future(value: request)
        }
        guard let rule = rules.first(where: { (rule) -> Bool in
            return rule.subject == request.url?.host
        }) else {
            return Future(value: request)
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.host = rule.host
        components?.port = rule.port

        var newRequest = request
        newRequest.url = components?.url
        
        return Future(value: newRequest)
    }
    
    func didSendRequest(_ request: URLRequest) {
        
    }
    
    func didReceiveResponse(_ response: ServiceResult) -> Future<ServiceResult, ServicePluginError> {
        return Future(value: response)
    }
}
