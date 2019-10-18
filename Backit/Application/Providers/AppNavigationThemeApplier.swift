import Foundation
import UIKit

class AppNavigationThemeApplier: NavigationThemeApplier {
    
    private static var didApplyGlobally = false
    
    func applyTo(_ navigationBar: UINavigationBar?) {
        if #available(iOS 13.0, *) {
            if let navigationBar = navigationBar {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.titleTextAttributes = [.foregroundColor: UIColor.bk.white]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.bk.white]
                appearance.backgroundColor = UIColor.bk.purple
                
                navigationBar.compactAppearance = appearance
                navigationBar.standardAppearance = appearance
                navigationBar.scrollEdgeAppearance = appearance
            }
            else if !AppNavigationThemeApplier.didApplyGlobally {
                let firstWindow = UIApplication.shared.windows.filter { !$0.isHidden }.first
//                let firstWindow = UIApplication.shared.connectedScenes
//                    .filter { $0.activationState == .foregroundActive }
//                    .map { $0 as? UIWindowScene }
//                    .compactMap { $0 }
//                    .first?.windows
//                    .filter { !$0.isHidden }.first // isKeyWindow is always false!
                guard let keyWindow = firstWindow else {
                    log.w("Could not find key window")
                    return
                }
                let frame = keyWindow.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
                let statusBar = UIView(frame: frame)
                statusBar.backgroundColor = UIColor.bk.purple
                keyWindow.addSubview(statusBar)
                AppNavigationThemeApplier.didApplyGlobally = true
            }
        
            return
        }

        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else {
            return
        }
        
        statusBar.backgroundColor = UIColor.bk.purple
    }
}
