/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

public struct GenericError: Error {
    public init() { }
}

public struct StringError: Error {
    
    let error: String
    
    var localizedDescription: String {
        return error
    }

    public init(error: String) {
        self.error = error
    }
}

// Emit when we fail to create a strong self from a weak self.
public struct WeakReferenceError: Error {
    public init() { }
}

public struct StoryboardError: Error {
    public init() { }
}
