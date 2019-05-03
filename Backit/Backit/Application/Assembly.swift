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
        container.register(ServiceRequester.self) { _ in
            return AlamofireServiceRequester()
        }
        
        container.register(ServicePluginProvider.self) { _ in
            let pluginProvider = ServicePluginProvider()
            // TODO: Register plugins
            return pluginProvider
        }.inObjectScope(.container)
        
        container.register(AppTheme.self) { _ in
            return AppTheme()
        }.inObjectScope(.container)
        
        container.register(AnyUITheme<AppTheme>.self) { resolver in
            let theme = resolver.resolve(AppTheme.self)!
            return AnyUITheme<AppTheme>(theme: theme)
        }
        
        container.register(HomepageProvider.self) { resolver in
            let service = resolver.resolve(AnalyticsService.self)!
            let metrics: AnalyticsPublisher<MetricAnalyticsEvent> = service.publisher()
            
            let provider = resolver.resolve(ProjectProvider.self)!
            return HomepageOrchestrator(provider: provider, metrics: metrics)
        }
        
        container.register(UIThemeApplier<AppTheme>.self) { resolver in
            let theme = UIThemeApplier<AppTheme>()
            theme.concrete = resolver.resolve(AnyUITheme<AppTheme>.self)!
            return theme
        }.inObjectScope(.container)
        
        // MARK: - Analytics
        
        // This must be a singleton to ensure that transactions can be tracked between dependencies. (i.e. start/cancel/stop)
        container.register(AnalyticsService.self) { resolver in
            let mixpanelListener = resolver.resolve(MixpanelAnalyticsListener.self)!
            let newRelicListener = resolver.resolve(NewRelicAnalyticsListener.self)!
            return AnalyticsService(listeners: [mixpanelListener, newRelicListener])
        }.inObjectScope(.container)

        container.register(Mixpanel.self) { resolver in
            return Mixpanel.sharedInstance(withToken: "020cda1e8529c09118ff8b03d5d79072")
        }.inObjectScope(.container)

        container.register(MixpanelAnalyticsListener.self) { resolver in
            let mixpanel = resolver.resolve(Mixpanel.self)!
            return MixpanelAnalyticsListener(mixpanel: mixpanel)
        }
        
        container.register(NewRelicAnalyticsListener.self) { resolver in
            return NewRelicAnalyticsListener()
        }
        
        // MARK: - Services
        
        container.register(Service.self) { resolver in
            let requester = resolver.resolve(ServiceRequester.self)!
            let pluginProvider = resolver.resolve(ServicePluginProvider.self)!
            return Service(environment: .qa, requester: requester, pluginProvider: pluginProvider)
        }
        
        container.register(AccountProvider.self) { resolver in
            let service = resolver.resolve(Service.self)!
            return AccountService(service: service)
        }
        
        container.register(ProjectProvider.self) { resolver in
            let service = resolver.resolve(Service.self)!
            return ProjectService(service: service)
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
        
        container.storyboardInitCompleted(ProjectFeedViewController.self) { resolver, controller in
            let theme = resolver.resolve(AppTheme.self)!
            let provider = resolver.resolve(HomepageProvider.self)!
            controller.inject(theme: AnyUITheme<AppTheme>(theme: theme), provider: provider)
        }
        
        container.storyboardInitCompleted(ChangelogViewController.self) { (resolver, controller) in
            
        }
    }
}
