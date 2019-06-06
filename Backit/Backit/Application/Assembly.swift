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
        container.register(URLSession.self) { _ in
            return URLSession(configuration: URLSessionConfiguration.default)
        }
        
        container.register(ServiceRequester.self) { _ in
            return AlamofireServiceRequester()
        }
        
        container.register(SessionProvider.self) { resolver in
            let userProvider = resolver.resolve(UserProvider.self)!
            let userStreamer = resolver.resolve(UserStreamer.self)!
            return SessionService(userProvider: userProvider, userStreamer: userStreamer)
        }
        .inObjectScope(.container)
        
        container.register(UserStreamer.self) { resolver in
            return UserStream()
        }
        .inObjectScope(.container)
        
        container.register(KeychainProvider.self) { _ in
            return AppKeychainProvider()
        }
        
        container.register(SignInProvider.self) { resolver in
            let keychainProvider = resolver.resolve(KeychainProvider.self)!
            let accountProvider = resolver.resolve(AccountProvider.self)!
            let presenterProvider = resolver.resolve(PresenterProvider.self)!
            return AppSignInProvider(keychainProvider: keychainProvider, accountProvider: accountProvider, presenterProvider: presenterProvider)
        }
        .inObjectScope(.container)
        
        container.register(AmazonService.self) { resolver in
            let urlSession = resolver.resolve(URLSession.self)!
            return AmazonService(urlSession: urlSession)
        }
        
        container.register(PresenterProvider.self) { resolver in
            return AppPresenterProvider()
        }
        
        container.register(AuthorizationServicePlugin.self) { resolver in
            let signInProvider = resolver.resolve(SignInProvider.self)!
            let sessionProvider = resolver.resolve(SessionProvider.self)!
            let accountProvider = resolver.resolve(AccountProvider.self)!
            return AuthorizationServicePlugin(signInProvider: signInProvider, sessionProvider: sessionProvider, accountProvider: accountProvider)
        }
        
        container.register(ServicePluginProvider.self) { resolver in
            let authorizationPlugin = resolver.resolve(AuthorizationServicePlugin.self)!
            
            let pluginProvider = ServicePluginProvider()
            pluginProvider.registerPlugin(authorizationPlugin)
            return pluginProvider
        }.inObjectScope(.container)
        
        container.register(AppTheme.self) { _ in
            return AppTheme()
        }.inObjectScope(.container)
        
        container.register(AnyUITheme<AppTheme>.self) { resolver in
            let theme = resolver.resolve(AppTheme.self)!
            return AnyUITheme<AppTheme>(theme: theme)
        }
        
        container.register(ProjectFeedProvider.self) { resolver in
            let service = resolver.resolve(AnalyticsService.self)!
            let metrics: AnalyticsPublisher<MetricAnalyticsEvent> = service.publisher()
            
            let provider = resolver.resolve(ProjectProvider.self)!
            return ProjectFeedProviderServer(provider: provider, metrics: metrics)
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
            return Service(environment: .qa, requester: requester)
        }
        .initCompleted { (resolver, service) in
            let pluginProvider = resolver.resolve(ServicePluginProvider.self)!
            service.pluginProvider = pluginProvider
        }
        
        container.register(AccountProvider.self) { resolver in
            let service = resolver.resolve(Service.self)!
            let sessionProvider = resolver.resolve(SessionProvider.self)!
            let amazoneService = resolver.resolve(AmazonService.self)!
            return AccountService(service: service, sessionProvider: sessionProvider, amazonService: amazoneService)
        }
        
        container.register(UserProvider.self) { resolver in
            let service = resolver.resolve(Service.self)!
            return UserService(service: service)
        }
        
        container.register(ProjectProvider.self) { resolver in
            let service = resolver.resolve(Service.self)!
            return ProjectService(service: service)
        }
        
        container.register(PhotoAlbumProvider.self) { resolver in
            let presenterProvider = resolver.resolve(PresenterProvider.self)!
            return AppPhotoAlbumProvider(presenterProvider: presenterProvider)
        }
        
        // MARK: - UIViewController Registration
        
        container.storyboardInitCompleted(UINavigationController.self) { (resolver, controller) in
            
        }

        container.storyboardInitCompleted(TabBarController.self) { (resolver, controller) in
            
        }
        
        container.storyboardInitCompleted(AccountViewController.self) { (resolver, controller) in
            let urlSession = resolver.resolve(URLSession.self)!
            let userStreamer = resolver.resolve(UserStreamer.self)!
            let signInProvider = resolver.resolve(SignInProvider.self)!
            let albumProvider = resolver.resolve(PhotoAlbumProvider.self)!
            let accountProvider = resolver.resolve(AccountProvider.self)!
            controller.inject(urlSession: urlSession, userStream: userStreamer, signInProvider: signInProvider, albumProvider: albumProvider, accountProvider: accountProvider)
        }

        container.storyboardInitCompleted(ProjectFeedViewController.self) { resolver, controller in
            let theme = resolver.resolve(AppTheme.self)!
            let provider = resolver.resolve(ProjectFeedProvider.self)!
            let userStreamer = resolver.resolve(UserStreamer.self)!
            let signInProvider = resolver.resolve(SignInProvider.self)!
            controller.inject(theme: AnyUITheme<AppTheme>(theme: theme), provider: provider, userStreamer: userStreamer, signInProvider: signInProvider)
        }
        
        container.storyboardInitCompleted(ChangelogViewController.self) { (resolver, controller) in
            
        }
        
        container.storyboardInitCompleted(SignInViewController.self) { resolver, controller in
            let accountProvider = resolver.resolve(AccountProvider.self)!
            controller.inject(accountProvider: accountProvider)
        }
    }
}
