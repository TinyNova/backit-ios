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
    public let status: AnalyticsTransaction.Status = .started
    public let startTime: Double // UNIX time in seconds
    
    public init(startTime: Double) {
        self.startTime = startTime
    }
}

public struct AnalyticsFinishedTransaction {
    public let status: AnalyticsTransaction.Status
    public let startTime: Double // UNIX time in seconds
    public let stopTime: Double // UNIX time in seconds
    public let totalTime: Double // Seconds elapsed from start to end
}
