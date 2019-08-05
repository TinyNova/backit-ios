/**
 * NewRelic Analytics Listener
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

private enum Constant {
    static let event = "MobileEvent"
    static let transaction = "MobileTransaction"
}

struct NewRelicEvent {
    let name: String
    let attributes: [AnyHashable: Any]?
    
    init(name: String, attributes: [AnyHashable: Any]? = nil) {
        self.name = name
        self.attributes = attributes
    }
    
    func allAttributes(with other: [AnyHashable: Any]? = nil) -> [AnyHashable: Any] {
        var attributes = self.attributes ?? [AnyHashable: Any]()
        
        // Add `event_type`
        attributes = attributes.merging(["event_type": name]) { (key, _) -> Any in
            return key
        }
        
        guard let other = other else {
            return attributes
        }
        
        // Add any additional attributes
        attributes = attributes.merging(other) { (key, _) -> Any in
            return key
        }
        return attributes
    }
}

protocol NewRelicEventTransformer {
    func transform() -> NewRelicEvent
}

class NewRelicAnalyticsListener: AnalyticsListener {
    
    func receive(_ event: AnalyticsEvent) {
        guard let transformer = event as? NewRelicEventTransformer else {
            return
        }

        let event = transformer.transform()
        NewRelic.recordCustomEvent(Constant.event, name: event.name, attributes: event.attributes)
    }
    
    func transaction(_ event: AnalyticsEvent, _ context: AnalyticsTransaction) {
        guard let transformer = event as? NewRelicEventTransformer else {
            return
        }
        
        let event = transformer.transform()
        var attributes = event.attributes ?? [AnyHashable: Any]()
        switch context {
        case .start(let context):
            attributes["status"] = context.status.asString
            attributes["startTime"] = context.startTime
        case .finish(let context):
            attributes["status"] = context.status.asString
            attributes["startTime"] = context.startTime
            attributes["stopTime"] = context.stopTime
            attributes["totalTime"] = context.totalTime
        }
        
        NewRelic.recordCustomEvent(Constant.transaction, name: event.name, attributes: attributes)
    }
}

// MARK: - Transformers

extension MetricAnalyticsEvent: NewRelicEventTransformer {
    
    func transform() -> NewRelicEvent {
        switch self {
        case .appColdLaunch:
            return NewRelicEvent(name: "app_cold_launch")
        case .homepage(let pageNumber):
            return NewRelicEvent(name: "homepage", attributes: ["pageNumber": pageNumber])
        case .pageLoad(let pageName, let context):
            var attributes: [AnyHashable: Any] = [
                "pageName": pageName
            ]
            if let dictionary = context?.asDictionary {
                attributes.merge(dictionary) { (key, _) -> Any in return key }
            }
            return NewRelicEvent(name: "pageLoad", attributes: attributes)
        }
    }
}

private extension AnalyticsTransaction.Status {
    var asString: String {
        switch self {
        case .started:
            return "started"
        case .cancelled:
            return "cancelled"
        case .stopped:
            return "stopped"
        }
    }
}
