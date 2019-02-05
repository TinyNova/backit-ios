/**
 Provides a way to track analytics.
 
 @copyright 2018 Upstart Illustration, LLC. All rights reserved.
 */

import Foundation

class AnalyticsService {
    
    private let listeners: [AnalyticsListener]
    
    private var transactions = [String /* Event location */: DispatchTime /* Time started */]()
    
    init(listeners: [AnalyticsListener]) {
        self.listeners = listeners
    }
    
    func send(_ event: AnalyticsEvent) {
        listeners.forEach { (listener) in
            listener.receive(event)
        }
    }
    
    func start( _ event: AnalyticsEvent) {
        let id = eventId(for: event)
        guard transactions[id] == nil else {
            print("WARN: Attempting to start a transaction which has already been started")
            return
        }
        transactions[id] = DispatchTime.now()
    }
    
    func cancel( _ event: AnalyticsEvent) {
        finishTransaction(event, status: .stopped)
    }

    func stop( _ event: AnalyticsEvent) {
        finishTransaction(event, status: .stopped)
    }
    
    func publisher<T: AnalyticsEvent>() -> AnalyticsPublisher<T> {
        return AnalyticsPublisher<T>(service: self)
    }
    
    private func eventId(for event: AnalyticsEvent) -> String {
        return String(describing: event)
    }
    
    private func finishTransaction(_ event: AnalyticsEvent, status: AnalyticsTransactionContext.Status) {
        guard let startTime = transactions[eventId(for: event)] else {
//            print("WARN: Must start a transaction before it can be \(status)")
            return
        }
        
        let endTime = DispatchTime.now()
        
        let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
        let totalTime = Double(nanoTime) / 1_000_000_000
        
        listeners.forEach { (listener) in
            listener.transaction(event, AnalyticsTransactionContext(status: status, startTime: startTime, endTime: endTime, totalTime: totalTime))
        }
    }
}
