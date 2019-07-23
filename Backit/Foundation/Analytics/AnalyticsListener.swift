/**
 
 @copyright 2019 Upstart Illustration, LLC. All rights reserved.
 */

import Foundation

public protocol AnalyticsListener {
    func receive(_ event: AnalyticsEvent)
    func transaction(_ event: AnalyticsEvent, _ context: AnalyticsTransaction)
}
