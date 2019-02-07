/**
 * MixPanel Analytics Listener
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
        // Transactions not needed for BI
    }
}

// MARK: - NewRelic event transformers (could be in another file)

extension BIAnalyticsEvent: MixpanelEventTransformer {
    
    func transform() -> MixpanelEvent {
        switch self {
        case .none:
            return MixpanelEvent(name: "none")
        }
    }
}
