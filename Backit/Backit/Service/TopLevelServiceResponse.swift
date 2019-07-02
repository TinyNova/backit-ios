/**
 Provides a way to decode top-level values that are not dictionary or arrays.
 
 This also provides transforming an alternate object in the case where the top-level object can not be decoded. In may cases the alternate object is an error message from the server.
 
 Example:
 
 If the server response is an `Int` (`123`) and can return an error with a message you can decode the top-level `Int` _or_ decode the `MyError` struct into the `alternate` var.
 Finally, you may set the fallback value in the scenario where the response could not set either the `value` or the `alternate`. This is useful when the server doesn't provide an `Int` _or_ an alternate type. The most common case is that it returns `null` -- the object couldn't be found. This isn't an error, but it's not a valid value either.
 
 ```
 // Example: MyEndpoint.swift
 
 // `struct`, `typealias`, and custom `decoder` is be defined in your respective `ServiceEndpoint`
 struct MyError {
    let status: Int
    let message: String
 }
 
 typealias ReturnType = TopLevelServiceResponse<Int, MyError>
 
 var decoder: ((Data?) -> ResponseType)? = { (data: Data?) -> ResponseType in
     // Decodes data and will set the fallback value to `0` if failing decodes.
     return TopLevelServiceResponse(from: data).fallback(0)
 }
 ```
 
 When the response is a valid `Int`:
 data = `123`
 print(response.value) // Optional<Int>(123)
 
 When the response is in error:
 data = `{"status": 500, "message": "My error message"}`
 print(response.alternate) // Optional(MyError(status: 500, message: "My error message"))
 
 When the response is `null` and the fallback value is `0`:
 data = `null`
 print(response.value) // Optional<Int>(0)
 
 License: MIT
 
 Copyright © 2019 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

class TopLevelServiceResponse<Value: Decodable, Alternate: Decodable>: Decodable {
    var value: Value?
    var alternate: Alternate?
    
    init(from data: Data?) {
        guard let data = data else {
            return
        }
        
        if let value = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Value {
            self.value = value
        }
        if let alternate = try? JSONDecoder().decode(Alternate.self, from: data) {
            self.alternate = alternate
        }
    }
    
    /**
     Assign a fallback value in the case where neither the `value` or the `alternate` var could be decoded.
     */
    func fallback(_ value: Value) -> TopLevelServiceResponse {
        guard self.value == nil, self.alternate == nil else {
            return self
        }
        self.value = value
        return self
    }
}
