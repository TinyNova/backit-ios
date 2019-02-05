/**
 Provides contextual information for a transaction.
 
 @copyright 2019 Upstart Illustration, LLC. All rights reserved.
 */


import Foundation

struct AnalyticsTransactionContext {
    enum Status {
        case cancelled
        case stopped
    }

    let status: AnalyticsTransactionContext.Status
    let startTime: DispatchTime
    let endTime: DispatchTime
    let totalTime: Double
}
