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
            return BannerMessage.error(title: "My goodness!", message: "Something funky is going on here! But don't you worry. We're on it!")
        case .validation(let message, let fields):
            guard fields.count > 0 else {
                // TODO: Better messaging...
                return BannerMessage.error(title: "My gawd, man!", message: message ?? "We don't know what the problem is...")
            }
            
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
