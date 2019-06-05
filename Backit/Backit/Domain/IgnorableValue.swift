/// Provides `Future`s with the ability to indicate that the operation has no value when it successfully completes. This is different than the `BrightFutures` `NoValue` as that `enum` indicates that the operation will _never_ be successful.
import Foundation

struct IgnorableValue {
    
}
