/**
 
 @copyright 2018 Upstart Illustration, LLC. All rights reserved.
 */

import Foundation

class AnalyticsPublisher<T: AnalyticsEvent> {
    
    private let service: AnalyticsService
    
    init(service: AnalyticsService) {
        self.service = service
    }
    
    func send(_ type: T) {
        service.send(type)
    }
}
