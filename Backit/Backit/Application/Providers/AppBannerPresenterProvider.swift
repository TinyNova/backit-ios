/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

class AppBannerProvider: BannerProvider {
    
    let messageProvider: BannerMessageProvider
    
    init(messageProvider: BannerMessageProvider) {
        self.messageProvider = messageProvider
    }
    
    func present(error: Error) {
        present(message: messageProvider.message(for: error))
    }
    
    func present(message: BannerMessage) {
        switch message.type {
        case .error:
            log.e("\(message.title ?? "NA"): \(message.message)")
        case .info:
            log.i("\(message.title ?? "NA"): \(message.message)")
        }
    }
}
