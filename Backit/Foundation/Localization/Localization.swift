/**
 Provides ability to make requests.
 
 License: MIT
 
 Copyright © 2019 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

public class Localization<T: LocalizationType> {
    public func t(_ token: T) -> String {
        return token.localize()
    }
}
