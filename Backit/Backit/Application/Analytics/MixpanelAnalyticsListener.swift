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
        if let transformer = event as? MixpanelEventTransformer {
            let event = transformer.transform()
            if let properties = event.properties {
                mixpanel.track(event.name, properties: properties)
            }
            else {
                mixpanel.track(event.name)
            }
        }
    }
    
    func start(_ event: AnalyticsEvent) {
        
    }
    
    func cancel(_ event: AnalyticsEvent) {
        
    }
    
    func stop(_ event: AnalyticsEvent) {
        
    }
}

// MARK: - NewRelic event transformers (could be in another file)

extension AppAnalyticsEvent: MixpanelEventTransformer {
    
    func transform() -> MixpanelEvent {
        switch self {
        case .homepage(let pageNumber):
            return MixpanelEvent(name: "homepage", properties: ["pageNumber": pageNumber])
        }
    }
}

extension DeveloperAnalyticsEvent: MixpanelEventTransformer {
    
    func transform() -> MixpanelEvent {
        switch self {
        case .pageLoad(let name, let context):
            var properties: [String: Any] = context?.asDictionary ?? [String: Any]()
            properties["page_name"] = name
            return MixpanelEvent(name: "page_load", properties: properties)
        case .homepageProjectListLoad(let pageNumber):
            return MixpanelEvent(name: "homepage_project_list_load", properties: ["pageNumber": pageNumber])
        }
    }
}
