/**
 Provides a way to track analytics.
 
 @copyright 2018 Upstart Illustration, LLC. All rights reserved.
 */

import Foundation

class AnalyticsService {
    
    private let listeners: [AnalyticsListener]
    
    init(listeners: [AnalyticsListener]) {
        self.listeners = listeners
    }
    
    func send(_ type: AnalyticsEvent) {
        listeners.forEach { (listener) in
            listener.receive(type)
        }
    }
    
    func start( _ type: AnalyticsEvent) {
        listeners.forEach { (listener) in
            listener.receive(type)
        }
    }
    
    func cancel( _ type: AnalyticsEvent) {
        listeners.forEach { (listener) in
            listener.receive(type)
        }
    }

    func stop( _ type: AnalyticsEvent) {
        listeners.forEach { (listener) in
            listener.receive(type)
        }
    }

    func publisher<T: AnalyticsEvent>() -> AnalyticsPublisher<T> {
        return AnalyticsPublisher<T>(service: self)
    }
}
