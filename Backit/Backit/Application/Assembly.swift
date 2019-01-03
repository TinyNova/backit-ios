/**
 *
 * Copyright © 2018 Backit. All rights reserved.
 */

import Foundation
import Swinject
import SwinjectStoryboard

class Assembly {
    
    let container: Container = SwinjectStoryboard.defaultContainer
    
    init() {
        container.register(AppTheme.self) { _ in
            return AppTheme()
        }.inObjectScope(.container)
        
        container.register(AnyUITheme<AppTheme>.self) { resolver in
            let theme = resolver.resolve(AppTheme.self)!
            return AnyUITheme<AppTheme>(theme: theme)
        }
        
        container.register(UIThemeApplier<AppTheme>.self) { resolver in
            let theme = UIThemeApplier<AppTheme>()
            theme.concrete = resolver.resolve(AnyUITheme<AppTheme>.self)!
            return theme
        }.inObjectScope(.container)
        
        // MARK: - UIViewController Registration
        
        container.storyboardInitCompleted(UITabBarController.self) { (resolver, controller) in
            
        }

        container.storyboardInitCompleted(HomepageViewController.self) { resolver, controller in
            let theme = resolver.resolve(AppTheme.self)!
            
            controller.inject(theme: AnyUITheme<AppTheme>(theme: theme))
        }
        
        container.storyboardInitCompleted(ChangelogViewController.self) { (resolver, controller) in
            
        }
    }
}
