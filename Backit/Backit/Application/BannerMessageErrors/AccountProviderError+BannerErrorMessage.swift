/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

extension AccountProviderError: BannerMessageError {
    var bannerMessage: BannerMessage {
        switch self {
        case .thirdParty,
             .failedToDecode,
             .generic:
            return BannerMessage.error(title: "My goodness!", message: "Something funky is going on! Don't worry. We're on it!")
        case .validation(let fields):
            let errors: [String] = fields.map { (fieldErrors) -> String in
                return "\(fieldErrors.key): \(fieldErrors.value.joined(separator: ", "))"
            }
            return BannerMessage.error(title: "Missing information", message: errors.joined(separator: "\n"))
        }
    }
}
