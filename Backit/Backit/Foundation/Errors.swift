/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

struct GenericError: Error {
    
}

struct StringError: Error {
    
    let error: String
    
    var localizedDescription: String {
        return error
    }
}

struct NotImplementedError: Error {
    
}

// Emit when we fail to create a strong self from a weak self.
struct WeakReferenceError: Error {
    
}

struct StoryboardError: Error {
    
}
