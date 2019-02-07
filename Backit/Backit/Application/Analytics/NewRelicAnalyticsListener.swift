/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

typealias NewRelicEvent = [String: Any]

protocol NewRelicEventTransformer {
    func transform() -> NewRelicEvent
}

class NewRelicAnalyticsListener: AnalyticsListener {
    
    func receive(_ event: AnalyticsEvent) {
        guard let transformer = event as? NewRelicEventTransformer else {
            return
        }

    }
    
    func transaction(_ event: AnalyticsEvent, _ context: AnalyticsTransaction) {
        
    }
}
