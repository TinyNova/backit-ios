/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit
import SpriteKit

import BKFoundation

class AppProgressOverlayProvider: ProgressOverlayProvider {
    
    private let presenterProvider: PresenterProvider
    private let pageProvider: PageProvider
    
    private var viewController: UIViewController?
    
    init(presenterProvider: PresenterProvider, pageProvider: PageProvider) {
        self.presenterProvider = presenterProvider
        self.pageProvider = pageProvider
    }
    
    func show() {
        guard let topViewController = presenterProvider.viewController else {
            return log.c("Failed to get the top view controller")
        }
        guard !(topViewController.presentingViewController is ProgressOverlayViewController) else {
            return log.w("Overlay has already been presented on top view controller")
        }
        guard let vc = pageProvider.progressOverlay() else {
            return log.c("Failed to get the progress overlay")
        }
        
        vc.prepareForModalPresentation(fullScreen: true)
        topViewController.modalTransitionStyle = .coverVertical
        topViewController.present(vc, animated: true, completion: nil)
        self.viewController = topViewController
    }
    
    func show(in viewController: UIViewController) {
        guard viewController.presentedViewController == nil else {
            return log.w("Overlay has already been presented")
        }
        guard let vc = pageProvider.progressOverlay() else {
            return log.c("Failed to get the progress overlay")
        }
        
        // FIXME: Is this not working? It didn't seem to be showing the overlay.
        vc.prepareForModalPresentation(fullScreen: false)
        viewController.modalTransitionStyle = .coverVertical
        viewController.present(vc, animated: true, completion: nil)
        self.viewController = viewController
    }
    
    func dismiss() {
        guard let viewController = viewController else {
            return log.w("Attempting to dismiss progress overlay when not previously shown")
        }
        
        // TODO: Finish the animation and then dismiss.
        viewController.dismiss(animated: true, completion: nil)
        self.viewController = nil
    }
}
