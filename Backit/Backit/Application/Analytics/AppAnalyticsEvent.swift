/**
 * Business intelligence events
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

enum AppAnalyticsEvent: AnalyticsEvent {
    case homepage(pageNumber: Int)
    case pageLoad(name: String, context: Encodable?)
}
