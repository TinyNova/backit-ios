/**
 * Business intelligence events
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

enum AppAnalyticsEvent: AnalyticsEvent {
    case appFirstLaunch
    case homepage(pageNumber: Int)
}
