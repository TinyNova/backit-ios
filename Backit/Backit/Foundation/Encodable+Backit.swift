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
        return (try? JSONSerialization.jsonObject(with: asJson)) as? [String: Any]
    }
}
