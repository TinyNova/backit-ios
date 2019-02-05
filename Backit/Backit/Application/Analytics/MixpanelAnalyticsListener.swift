/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import Mixpanel

struct MixpanelEvent {
    let name: String
    let properties: [String: Any]?
    
    init(name: String, properties: [String: Any]? = nil) {
        self.name = name
        self.properties = properties
    }
}

protocol MixpanelEventTransformer {
    func transform() -> MixpanelEvent
}

class MixpanelAnalyticsListener: AnalyticsListener {    
    
    private let mixpanel: Mixpanel
    
    init(mixpanel: Mixpanel) {
        self.mixpanel = mixpanel
    }
    
    func receive(_ event: AnalyticsEvent) {
        guard let transformer = event as? MixpanelEventTransformer else {
            return
        }
        
        let event = transformer.transform()
        if let properties = event.properties {
            mixpanel.track(event.name, properties: properties)
        }
        else {
            mixpanel.track(event.name)
        }
    }
    
    func transaction(_ event: AnalyticsEvent, _ context: AnalyticsTransaction) {
        guard let transformer = event as? MixpanelEventTransformer else {
            return
        }

        let event = transformer.transform()
        var properties = event.properties ?? [String: Any]()
        switch context {
        case .start(let context):
            properties["status"] = context.status.asString
            properties["startTime"] = context.startTime
        case .finish(let context):
            properties["status"] = context.status.asString
            properties["startTime"] = context.startTime
            properties["stopTime"] = context.stopTime
            properties["totalTime"] = context.totalTime
        }
        mixpanel.track(event.name, properties: properties)
    }
}

// MARK: - NewRelic event transformers (could be in another file)

extension AppAnalyticsEvent: MixpanelEventTransformer {
    
    func transform() -> MixpanelEvent {
        switch self {
        case .homepage(let pageNumber):
            return MixpanelEvent(name: "homepage", properties: ["pageNumber": pageNumber])
        case .pageLoad(let pageName, let context):
            var properties: [String: Any] = [
                "pageName": pageName
            ]
            if let dictionary = context?.asDictionary {
                properties.merge(dictionary) { (key, _) -> Any in return key }
            }
            return MixpanelEvent(name: "pageLoad", properties: properties)
        }
    }
}

extension DeveloperAnalyticsEvent: MixpanelEventTransformer {
    
    func transform() -> MixpanelEvent {
        switch self {
        case .appColdLaunch:
            return MixpanelEvent(name: "app_cold_launch")
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
