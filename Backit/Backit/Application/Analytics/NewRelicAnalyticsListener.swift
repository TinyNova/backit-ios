/**
 * NewRelic Analytics Listener
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

typealias NewRelicEvent = (name: String, attributes: [AnyHashable: Any]?)

protocol NewRelicEventTransformer {
    func transform() -> NewRelicEvent
}

class NewRelicAnalyticsListener: AnalyticsListener {
    
    func receive(_ event: AnalyticsEvent) {
        guard let transformer = event as? NewRelicEventTransformer else {
            return
        }

        let event = transformer.transform()
        NewRelic.recordCustomEvent(event.name, attributes: event.attributes)
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
        NewRelic.recordCustomEvent(event.name, attributes: attributes)
    }
}

// MARK: - Transformers

extension MetricAnalyticsEvent: NewRelicEventTransformer {
    
    func transform() -> NewRelicEvent {
        switch self {
        case .appColdLaunch:
            return (name: "app_cold_launch", attributes: nil)
        case .homepage(let pageNumber):
            return (name: "homepage", attributes: ["pageNumber": pageNumber])
        case .pageLoad(let pageName, let context):
            var attributes: [AnyHashable: Any] = [
                "pageName": pageName
            ]
            if let dictionary = context?.asDictionary {
                attributes.merge(dictionary) { (key, _) -> Any in return key }
            }
            return (name: "pageLoad", attributes: attributes)
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
