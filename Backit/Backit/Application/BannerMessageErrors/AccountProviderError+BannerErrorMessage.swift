/**
 * TODO: I18N
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

extension AccountProviderError: BannerMessageError {
    
    private static var i18n = Localization<Appl10n>()
    
    var bannerMessage: BannerMessage {
        switch self {
        case .thirdParty,
             .failedToDecode,
             .generic:
            return BannerMessage.error(title: "My goodness!", message: "Something funky is going on! Don't worry. We're on it!")
        case .validation(let message, let fields):
            var errors = [String]()
            fields.forEach { (record: (key: AccountValidationField, value: [String])) in
                errors.append("Field: \(AccountProviderError.i18n.t(.field(record.key)))")
                record.value.forEach { (error) in
                    errors.append(" - \(error)")
                }
            }
            return BannerMessage.error(title: message, message: errors.joined(separator: "\n"))
        }
    }
}
