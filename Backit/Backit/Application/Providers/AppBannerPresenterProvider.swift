/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

class AppBannerProvider: BannerProvider {
    
    let messageProvider: BannerMessageProvider
    
    init(messageProvider: BannerMessageProvider) {
        self.messageProvider = messageProvider
    }
    
    func present(error: Error, in viewController: UIViewController?) {
        present(message: messageProvider.message(for: error), in: viewController)
    }
    
    func present(message: BannerMessage, in viewController: UIViewController?) {
        guard let view = viewController?.view else {
            log.w("Attempting to display banner in a `UIViewController` that has no `view`")
            return
        }
        
        // NOTE: This banner must be the entire size of the screen so that it can capture all taps.
        // TODO: Add `TapGestureRecognizer` and dismiss the view.
        let size = UIScreen.main.bounds.size
        let bannerView = BannerView(frame: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        view.addSubview(bannerView)
        view.bringSubviewToFront(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        bannerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        bannerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        bannerView.show(message: message)
        
        switch message.type {
        case .error:
            log.e("\(message.title ?? "NA"): \(message.message)")
        case .info:
            log.i("\(message.title ?? "NA"): \(message.message)")
        }
    }
}
