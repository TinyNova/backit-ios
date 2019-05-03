/**
 Provides ability to make requests.
 
 License: MIT
 
 Copyright © 2019 Upstart Illustration LLC. All rights reserved.
 */

import Foundation
import BrightFutures

extension Promise {
    func reduce<V>(_ initial: T, _ collection: [V], reducer: @escaping (T, V) -> Future<T, E>) {
        guard collection.count > 0 else {
            return success(initial)
        }
        
        var collection = collection
        let value = collection.removeFirst()
        reducer(initial, value)
            .onSuccess { [weak self] (value) in
                self?.reduce(value, collection, reducer: reducer)
            }
            .onFailure { [weak self] (error) in
                self?.failure(error)
        }
    }
}

extension Future {
    static func reduce<V>(_ initial: T, _ collection: [V], reducer: @escaping (T, V) -> Future<T, E>) -> Future<T, E> {
        guard collection.count > 0 else {
            return Future<T, E>(value: initial)
        }
        
        let promise = Promise<T, E>()
        promise.reduce(initial, collection, reducer: reducer)
        return promise.future
    }
}
