/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

@discardableResult
func with<T>(_ item: T, update: (inout T) throws -> Void) rethrows -> T {
    var this = item
    try update(&this)
    return this
}
