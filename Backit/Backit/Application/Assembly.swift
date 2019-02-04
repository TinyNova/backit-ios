/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import Mixpanel
import Swinject
import SwinjectStoryboard

class Assembly {
    
    let container: Container = SwinjectStoryboard.defaultContainer
    
    init() {
        container.register(AnalyticsService.self) { resolver in
            let listeners = resolver.resolve([AnalyticsListener].self)!
            return AnalyticsService(listeners: listeners)
        }
        
        container.register(ServiceRequester.self) { _ in
            return AlamofireServiceRequester()
        }
        
        container.register(AppTheme.self) { _ in
            return AppTheme()
        }.inObjectScope(.container)
        
        container.register(AnyUITheme<AppTheme>.self) { resolver in
            let theme = resolver.resolve(AppTheme.self)!
            return AnyUITheme<AppTheme>(theme: theme)
        }
        
        container.register(HomepageProvider.self) { resolver in
            let provider = resolver.resolve(ProjectProvider.self)!
            return HomepageOrchestrator(provider: provider)
        }
        
        container.register(UIThemeApplier<AppTheme>.self) { resolver in
            let theme = UIThemeApplier<AppTheme>()
            theme.concrete = resolver.resolve(AnyUITheme<AppTheme>.self)!
            return theme
        }.inObjectScope(.container)
        
        // MARK: - Analytics
        
        /// The reason AnalyticsListeners are not part of the `AnalyticsService` register as it allows that registration to happen in a different module assembly.
        container.register([AnalyticsListener].self) { resolver in
            var listeners = [AnalyticsListener]()
            
            // Mixpanel
            if let mixpanel = Mixpanel.sharedInstance() {
                print("ERROR: Mixpanel has no shared instance")
                let listener = MixpanelAnalyticsListener(mixpanel: mixpanel)
                listeners.append(listener)
            }
            
            return listeners
        }
        
        // MARK: - Services
        
        container.register(ProjectProvider.self) { resolver in
            let requester = resolver.resolve(ServiceRequester.self)!
            return ProjectService(environment: .prod, requester: requester, plugins: [])
        }
        
        // MARK: - UIViewController Registration
        
        container.storyboardInitCompleted(UINavigationController.self) { (resolver, controller) in
            
        }

        container.storyboardInitCompleted(UITabBarController.self) { (resolver, controller) in
            
        }

        container.storyboardInitCompleted(HomepageViewController.self) { resolver, controller in
            let theme = resolver.resolve(AppTheme.self)!
            let provider = resolver.resolve(HomepageProvider.self)!
            controller.inject(theme: AnyUITheme<AppTheme>(theme: theme), provider: provider)
        }
        
        container.storyboardInitCompleted(ChangelogViewController.self) { (resolver, controller) in
            
        }
    }
}
