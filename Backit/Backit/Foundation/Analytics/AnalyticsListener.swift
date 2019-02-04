/**
 
 @copyright 2018 Upstart Illustration, LLC. All rights reserved.
 */

import Foundation

protocol AnalyticsListener {
    func receive(_ event: AnalyticsEvent)
    func start(_ event: AnalyticsEvent)
    func cancel(_ event: AnalyticsEvent)
    func stop(_ event: AnalyticsEvent)
}
