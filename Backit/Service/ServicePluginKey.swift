/**
 Provides a key to map to a `ServicePlugin`s.
 
 This file should be updated to reflect your app's respective plugins. Every app will have their own unique plugins. To install a plugin for an endpoint, you must register your plugin(s) with either `Service.registerPlugin()` or `Service.registerPlugins()`.
 
 License: MIT
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

enum ServicePluginKey: Equatable {
    /// A special key which will _always_ be used, regardless of whether it has been configured by the `ServiceEndpoint`.
    case alwaysUse
    
    /// Adds `Authorization: bearer [session token]` into request.
    case authorization
}
