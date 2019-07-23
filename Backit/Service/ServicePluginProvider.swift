/**
 Manages and provides `ServicePlugin`s for `ServiceEndpoint`s.
 
 License: MIT
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

class ServicePluginProvider {
    
    private var plugins: [ServicePlugin] = []
    private var alwaysPlugins: [ServicePlugin] = []
    
    /**
     Register a plugin.
     
     - parameter plugin: A plugin to register.
     */
    func registerPlugin(_ plugin: ServicePlugin) {
        if plugin.key == .alwaysUse {
            self.alwaysPlugins.append(plugin)
        }
        else {
            self.plugins.append(plugin)
        }
    }
    
    /**
     Register a list of plugins.
     
     - parameter plugins: A list of plugins to register
     */
    func registerPlugins(_ plugins: [ServicePlugin]) {
        plugins.forEach { (plugin) in
            registerPlugin(plugin)
        }
    }
    
    /**
     Returns a list of plugins for a given `Endpoint`.
     
     - parameter endpoint: The `Endpoint` to return plugins for
     - returns: A list of `ServicePlugin`s required by the `Endpoint`
     */
    func pluginsFor<T: ServiceEndpoint>(_ endpoint: T) throws -> [ServicePlugin] {
        guard let endpointPlugins = endpoint.plugins else {
            return alwaysPlugins
        }
        
        var returnPlugins: [ServicePlugin] = plugins.filter { (plugin) -> Bool in
            return endpointPlugins.contains(plugin.key)
        }
        if endpointPlugins.count != returnPlugins.count {
            throw ServiceError.requiredPluginsNotFound(endpointPlugins)
        }
        
        returnPlugins.append(contentsOf: alwaysPlugins)
        
        return returnPlugins
    }
}
