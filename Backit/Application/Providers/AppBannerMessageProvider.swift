/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

protocol BannerMessageError {
    var bannerMessage: BannerMessage { get }
}

class AppBannerMessageProvider: BannerMessageProvider {
    func message(for error: Error) -> BannerMessage {
        guard let convertible = error as? BannerMessageError else {
            return BannerMessage(type: .error, title: nil, message: error.localizedDescription, button1: nil, button2: nil)
        }
        
        return convertible.bannerMessage
    }
}
