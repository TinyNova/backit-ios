/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import SpriteKit
import UIKit

class AppBannerProvider: BannerProvider {
    
    private let messageProvider: BannerMessageProvider
    
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
        
        let size = UIScreen.main.bounds.size
        let bannerView = BannerView(frame: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        bannerView.bannerDelegate = self

        view.addSubview(bannerView)
        view.bringSubviewToFront(bannerView)

        constrain(bannerView, to: view)
        
        // TODO: Create one banner per UIViewController? It seems like this should be smarter.
        bannerView.show(message: message, paddingTop: view.frame.origin.y)
        
        switch message.type {
        case .error:
            log.e("\(message.title ?? "NA"): \(message.message)")
        case .info:
            log.i("\(message.title ?? "NA"): \(message.message)")
        case .warning:
            log.w("\(message.title ?? "NA"): \(message.message)")
        }
    }
    
    /// The size of the banner is the size of the screen. This ensures that all taps can be captured.
    private func constrain(_ bannerView: BannerView, to view: UIView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        bannerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        bannerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    }
}

extension AppBannerProvider: BannerViewDelegate {
    func didDismissBanner(_ bannerView: BannerView) {
        bannerView.removeFromSuperview()
    }
}
