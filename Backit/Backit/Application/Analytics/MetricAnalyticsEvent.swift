/**
 * Developer analytics events.
 *
 * These events include performance, warnings, errors, and any other non BI related analytics events.
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

enum MetricAnalyticsEvent: AnalyticsEvent {
    case appColdLaunch
    case homepage(pageNumber: Int)
    case pageLoad(name: String, context: Encodable?)
}
