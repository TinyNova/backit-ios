/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

enum BannerType {
    case info
    case error
    case warning
}

struct BannerButton {
    let title: String
    let callback: () -> Void
}

struct BannerMessage {
    let type: BannerType
    let title: String?
    let message: String
    let button1: BannerButton?
    let button2: BannerButton?
    
    static func error(title: String?, message: String) -> BannerMessage {
        return BannerMessage(type: .error, title: title, message: message, button1: nil, button2: nil)
    }
}

protocol BannerMessageProvider {
    func message(for error: Error) -> BannerMessage
}

protocol BannerProvider {
    func present(error: Error, in viewController: UIViewController?)
    func present(message: BannerMessage, in viewController: UIViewController?)
}
