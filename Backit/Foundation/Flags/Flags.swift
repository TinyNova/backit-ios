/**
 Provides API to register and retrieve values for respective feature flags and A/B flags.
 
 This is the class you would use to determine if a feature is enabled, to get an A/B boolean value/multi-variant value.
 
 License: MIT
 
 Copyright © 2019 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

class Flags {
    
    private let environment: Environment
    
    private var flagValues = [FlagValue]()
    
    init(environment: Environment) {
        self.environment = environment
    }
    
    /**
     Return the respective value for the flag.
     
     NOTE: The flag type must be correct otherwise this throws a fatal exception.
     
     - parameter flag: The flag to derive value for
     - parameter type: The type of value represented by the flag
     - returns: The flag's respective value. `default` if the value is not set.
     */
    func value<T>(for flagId: FlagID, _ type: T.Type) -> T {
        guard let flagValue = flagValueType(for: flagId) as? Flag<T> else {
            fatalError("Flat not found with ID \(flagId). Register flags with `register(flag:)`")
        }
        
        guard let value = flagValue.value else {
            return flagValue.default
        }
        
        guard flagValue.available.contains(environment) else {
            return flagValue.default
        }
        
        return value
    }
    
    /**
     Returns whether a flag is enabled.
     
     NOTE: This is a convenience function for boolean flags (a non multi-variant value).
     
     - parameter flag: The flag to determine enable status
     - returns: `true` when the flag is enabled. `false`, otherwise
     */
    func isEnabled(for flagId: FlagID) -> Bool {
        return value(for: flagId, Bool.self)
    }
    
    /**
     Register a flag.
     
     This will emit a warning if the flag is already registered. This will not register the flag it has already been registered.
     
     - parameter flag: The flag to register.
     */
    func register(flag: FlagValue) {
        guard flagValueType(for: flag.id) == nil else {
            log.w("Attempting to register more than one FlagValue for flag \(flag.id)")
            return
        }
        flagValues.append(flag)
    }
    
    /**
     Register one or more flags.
     
     This will emit a warning if one or more of the flags is already registered. This will not register a flag that has already been registered.
     
     - parameter flags: An array of flags to register
     */
    func register(flags: [FlagValue]) {
        for flag in flags {
            register(flag: flag)
        }
    }
    
    /**
     Attempts to set the value of a server flag to its respective `FlagValue`.
     
     This should be used when setting a value retrieved by the server to a respective `FeatureValue.value` flag.
     
     This does nothing if `key` is not found.
     
     - parameter key: The key name of the `FlagValue`
     - parameter value: The value to associate to the `FlagValue`
     */
    func setValue(key: String, value: Any) {
        guard let flagValue = flagValueType(for: key) else {
            log.w("A flag with key \(key) does not exist")
            return
        }
        
        flagValue.setValue(value)
    }
    
    /**
     Attempts to set the value of a flag to its respective `FlagValue`.
     
     This can be used to set a `FeatureValue.value` when reading from a local store, such as `UserDefaults`.
     
     - parameter flagId: The `FlagID` for the `FlagValue`
     - parameter value: The value to associate to the `FlagValue`
     */
    func setValue(for flagId: FlagID, value: Any) {
        guard let flagValue = flagValueType(for: flagId) else {
            log.w("Flag w/ ID  \(flagId) has not been registered")
            return
        }
        
        flagValue.setValue(value)
    }
    
    // MARK: - Private
    
    private func flagValueType(for flagId: FlagID) -> FlagValue? {
        return flagValues.first() { (flagValue) -> Bool in
            return flagValue.id == flagId
        }
    }
    
    private func flagValueType(for key: String) -> FlagValue? {
        return flagValues.first() { (flagValue) -> Bool in
            return flagValue.key == key
        }
    }
}
