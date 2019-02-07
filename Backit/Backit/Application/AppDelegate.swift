/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Mixpanel
import UIKit

private enum Constant {
    static let appIdKey = "ApplicationUniqueIdentifier"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var assembly = Assembly()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        _ = assembly.container.resolve(Mixpanel.self)!
        
        startNewRelic()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    private func startNewRelic() {
        NewRelic.start(withApplicationToken: "AA9d4dc7b3da71620e9db3f083b055f33fbd30e104")

        let userDefaults = UserDefaults.standard
        let deviceId: String
        if let storedDeviceId = userDefaults.object(forKey: Constant.appIdKey) as? String {
            deviceId = storedDeviceId
        }
        else if let vendorId = UIDevice.current.identifierForVendor?.uuidString {
            deviceId = vendorId
            userDefaults.set(vendorId, forKey: Constant.appIdKey)
        }
        else {
            deviceId = NSUUID().uuidString
            userDefaults.set(deviceId, forKey: Constant.appIdKey)
        }
        NewRelic.setUserId(deviceId)
    }
}
