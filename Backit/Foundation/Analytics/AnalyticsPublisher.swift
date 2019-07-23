/**
 
 @copyright 2018 Upstart Illustration, LLC. All rights reserved.
 */

import Foundation

public class AnalyticsPublisher<T: AnalyticsEvent> {
    
    private let service: AnalyticsService
    
    public init(service: AnalyticsService) {
        self.service = service
    }
    
    public func send(_ type: T) {
        service.send(type)
    }
    
    public func start(_ type: T) {
        service.start(type)
    }
    
    public func cancel(_ type: T) {
        service.cancel(type)
    }
    
    public func stop(_ type: T) {
        service.stop(type)
    }
}
