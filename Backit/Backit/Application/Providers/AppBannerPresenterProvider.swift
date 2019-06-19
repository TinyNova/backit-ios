/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

class AppBannerProvider: BannerProvider {
    func present(error: Error) {
        log.e(error.localizedDescription)
    }
    
    func present(type: BannerType, title: String?, message: String) {
        switch type {
        case .error:
            log.e("\(title ?? "NA"): \(message)")
        case .info:
            log.i("\(title ?? "NA"): \(message)")
        }
    }
}
