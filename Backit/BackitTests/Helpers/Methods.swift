import Foundation
import Nimble
import Quick

func crankRunLoop() {
    expect(true).toEventually(beTrue())
}

func compare<T: Equatable>(_ lhs: T?, _ rhs: T?) -> Bool {
    if lhs == nil && rhs == nil {
        return true
    }
    guard let lhs = lhs, let rhs = rhs else {
        return false
    }
    return lhs == rhs
}

func compare<T: Equatable>(_ lhs: [T]?, _ rhs: [T]?) -> Bool {
    if lhs == nil && rhs == nil {
        return true
    }
    guard let lhs = lhs, let rhs = rhs else {
        return false
    }
    return lhs == rhs
}

func compare<T: Equatable>(_ lhs: [T?], _ rhs: [T?]) -> Bool {
    guard lhs.count == rhs.count else {
        return false
    }
    for (index, item) in lhs.enumerated() {
        if !compare(item, rhs[index]) {
            return false
        }
    }
    return true
}
