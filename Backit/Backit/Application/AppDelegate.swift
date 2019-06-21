/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
//import Mixpanel
import UIKit

private enum Constant {
    static let appIdKey = "ApplicationUniqueIdentifier"
}

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var assembly = Assembly()

    private var accountProvider: AccountProvider!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // FIXME: Make sure that no requests are made before NewRelic has a chance to start. This may require requests being deferred until NewRelic starts.
        startNewRelic()
        
//        _ = assembly.container.resolve(Mixpanel.self)!

        accountProvider = assembly.container.resolve(AccountProvider.self)!
        silentlyLoginUser()
        initializeGoogleSignIn()
//        displayAccountServiceHealth()
//        logout()

        // TODO: Display semi-transparent navigation bar
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barStyle = .black
        UINavigationBar.appearance().tintColor = UIColor.fromHex(0xffffff)
        UINavigationBar.appearance().barTintColor = UIColor.fromHex(0x130a33)
        UINavigationBar.appearance().shadowImage = UIImage()

//        UIFont.displayAllAvailableFonts()

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let provider = assembly.container.resolve(GoogleProvider.self)!
        return provider.appDidOpen(url: url, with: options)
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

    // MARK: Private methods

    private func silentlyLoginUser() {
        let keychainProvider = assembly.container.resolve(KeychainProvider.self)!
        keychainProvider.userSession()
            .onSuccess { [weak self] userSession in
                self?.accountProvider.silentlyReauthenticate(accountId: userSession.accountId, refreshToken: userSession.refreshToken)
                    .onSuccess { (userSession) in
                        keychainProvider.saveUserSession(userSession)
                            .onSuccess { _ in
                                log.i("Successfully silently reauthenticated")
                            }
                            .onFailure { error in
                                log.e("Failed to save credentials \(error)")
                            }
                    }
                    .onFailure { (error) in
                        keychainProvider.removeAll().onComplete { _ in
                            log.i("Removed credentials")
                    }
                }
            }
            .onFailure { error in
                return log.i("Failed to get session. Skipping silent reauthentication.")
            }
    }
    
    private func displayAccountServiceHealth() {
        accountProvider.health()
            .onSuccess { health in
                log.i(String(describing: health))
            }
            .onFailure { error in
                log.e(error)
            }
    }
    
    private func initializeGoogleSignIn() {
        let provider = assembly.container.resolve(GoogleProvider.self)!
        provider.appDidLaunch()
    }
    
    private func logout() {
        let provider = assembly.container.resolve(GoogleProvider.self)!
        _ = provider.logout()
    }
    
    // FIXME: Move this into a dependency.
    private func startNewRelic() {
        NewRelic.enableFeatures([
            .NRFeatureFlag_HttpResponseBodyCapture,
            .NRFeatureFlag_RequestErrorEvents,
            .NRFeatureFlag_NSURLSessionInstrumentation,
            .NRFeatureFlag_NetworkRequestEvents
        ])
        NewRelic.disableFeatures([
            .NRFeatureFlag_CrashReporting,
            .NRFeatureFlag_DefaultInteractions,
            .NRFeatureFlag_DistributedTracing,
            .NRFeatureFlag_ExperimentalNetworkingInstrumentation,
            .NRFeatureFlag_HandledExceptionEvents,
            .NRFeatureFlag_SwiftInteractionTracing,
            .NRFeatureFlag_WebViewInstrumentation
        ])
        NewRelic.start(withApplicationToken: "AA9d4dc7b3da71620e9db3f083b055f33fbd30e104")
        
        // Set user ID which data can be correlated to
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
