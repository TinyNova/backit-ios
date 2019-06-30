/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
import Foundation

enum ShareProviderError: Error {
    case generic(Error)
    case invalidUrl
}

protocol ShareProvider {
    
    /**
     * Share a URL on social media.
     *
     * - parameter: The URL to share
     * - parameter: The view component to show share pop-up in tablet contexts
     */
    func shareUrl(_ url: URL?, from sender: UIView) -> Future<IgnorableValue, ShareProviderError>
}
