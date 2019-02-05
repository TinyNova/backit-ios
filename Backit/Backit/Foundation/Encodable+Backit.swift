/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

extension Encodable {
    
    var asJson: Data {
        return try! JSONEncoder().encode(self)
    }
    
    var asDictionary: [String: Any]? {
        // Already a dictionary
        if let dict = self as? [String: Any] {
            return dict
        }
        // Self is an object
        return (try? JSONSerialization.jsonObject(with: asJson)) as? [String: Any]
    }
}
