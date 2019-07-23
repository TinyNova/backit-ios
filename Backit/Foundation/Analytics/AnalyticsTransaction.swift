/**
 Provides contextual information for a transaction.
 
 @copyright 2019 Upstart Illustration, LLC. All rights reserved.
 */

import Foundation

public enum AnalyticsTransaction {
    public enum Status {
        case started
        case cancelled
        case stopped
    }

    case start(AnalyticsStartedTransaction)
    case finish(AnalyticsFinishedTransaction)
}

public struct AnalyticsStartedTransaction {
    let status: AnalyticsTransaction.Status = .started
    let startTime: Double // UNIX time in seconds
    
    public init(startTime: Double) {
        self.startTime = startTime
    }
}

public struct AnalyticsFinishedTransaction {
    let status: AnalyticsTransaction.Status
    let startTime: Double // UNIX time in seconds
    let stopTime: Double // UNIX time in seconds
    let totalTime: Double // Seconds elapsed from start to end
}
