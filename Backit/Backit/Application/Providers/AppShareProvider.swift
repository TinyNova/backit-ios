/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation
import UIKit

class AppShareProvider: ShareProvider {
    
    private let presenterProvider: PresenterProvider
    
    private var promise: Promise<IgnorableValue, ShareProviderError>?
    
    init(presenterProvider: PresenterProvider) {
        self.presenterProvider = presenterProvider
    }
    
    func shareUrl(_ url: URL?, from sender: UIView) -> Future<IgnorableValue, ShareProviderError> {
        if let promise = promise {
            return promise.future
        }
        guard let url = url else {
            return Future(error: .invalidUrl)
        }
        
        let promise = Promise<IgnorableValue, ShareProviderError>()
        _ = promise.future.andThen { [weak self] _ in
            self?.promise = nil
        }
        
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { [weak self] (actvityType: UIActivity.ActivityType?, shared: Bool, returnedItems: [Any]?, error: Error?) -> Void in
            promise.success(IgnorableValue())
            self?.presenterProvider.dismiss(activityViewController, completion: nil)
        }
        activityViewController.popoverPresentationController?.sourceView = sender
        presenterProvider.present(activityViewController, completion: nil)
        
        self.promise = promise
        return promise.future
    }
}
