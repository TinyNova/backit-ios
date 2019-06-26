/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
//import Mixpanel
import Swinject
import SwinjectStoryboard

private enum Config {
    
    /// The environment the app is configured to run in
    static var environment: Environment {
        // TODO: Always return .prod when delivering to the App Store to prevent Development or QA configuration from going to Production.
        
        return .qa
    }
    
    /// Toggles debug logging for all services that support it
    static var debug: Bool = false
}

class Assembly {
    
    let container: Container = SwinjectStoryboard.defaultContainer
    
    init() {
        container.register(DispatchQueue.self) { _ in
            return DispatchQueue.main
        }
        
        container.register(URLSession.self) { _ in
            return URLSession(configuration: URLSessionConfiguration.default)
        }
        
        container.register(ServiceRequester.self) { _ in
            if Config.environment == .dev {
                let sessionManager = AlamofireSessionManagerFactory.makeDevelopment()
                return AlamofireServiceRequester(sessionManager: sessionManager)
            }
            
            let sessionManager = AlamofireSessionManagerFactory.makeProduction()
            return AlamofireServiceRequester(sessionManager: sessionManager)
        }
        
        container.register(UserSessionStreamer.self) { resolver in
            let userProvider = resolver.resolve(UserProvider.self)!
            let userStreamer = resolver.resolve(UserStreamer.self)!
            return UserSessionStream(userProvider: userProvider, userStreamer: userStreamer)
        }
        .inObjectScope(.container)
        
        container.register(UserAvatarStreamer.self) { resolver in
            return UserAvatarStream()
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
            let pageProvider = resolver.resolve(PageProvider.self)!
            let facebookProvider = resolver.resolve(FacebookProvider.self)!
            let googleProvider = resolver.resolve(GoogleProvider.self)!
            return AppSignInProvider(keychainProvider: keychainProvider, accountProvider: accountProvider, presenterProvider: presenterProvider, pageProvider: pageProvider, facebookProvider: facebookProvider, googleProvider: googleProvider)
        }
        .inObjectScope(.container)
        
        container.register(ExternalSignInProvider.self) { resolver in
            let urlSession = resolver.resolve(URLSession.self)!
            let accountProvider = resolver.resolve(AccountProvider.self)!
            let pageProvider = resolver.resolve(PageProvider.self)!
            let presenterProvider = resolver.resolve(PresenterProvider.self)!
            return AppExternalSignInProvider(urlSession: urlSession, accountProvider: accountProvider, pageProvider: pageProvider, presenterProvider: presenterProvider)
        }
        .inObjectScope(.container)
        
        container.register(AmazonService.self) { resolver in
            let urlSession = resolver.resolve(URLSession.self)!
            return AmazonService(urlSession: urlSession)
        }
        
        container.register(PresenterProvider.self) { resolver in
            return AppPresenterProvider()
        }
        
        container.register(BannerMessageProvider.self) { resolver in
            return AppBannerMessageProvider()
        }
        
        container.register(BannerProvider.self) { resolver in
            let messageProvider = resolver.resolve(BannerMessageProvider.self)!
            return AppBannerProvider(messageProvider: messageProvider)
        }
        
        container.register(ProgressOverlayProvider.self) { resolver in
            let presenterProvider = resolver.resolve(PresenterProvider.self)!
            let pageProvider = resolver.resolve(PageProvider.self)!
            return AppProgressOverlayProvider(presenterProvider: presenterProvider, pageProvider: pageProvider)
        }
        
        container.register(PageProvider.self) { resolver in
            return AppPageProvider()
        }
        
        container.register(AuthorizationServicePlugin.self) { resolver in
            let signInProvider = resolver.resolve(SignInProvider.self)!
            let sessionStream = resolver.resolve(UserSessionStreamer.self)!
            let accountProvider = resolver.resolve(AccountProvider.self)!
            return AuthorizationServicePlugin(signInProvider: signInProvider, sessionStream: sessionStream, accountProvider: accountProvider)
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
//            let mixpanelListener = resolver.resolve(MixpanelAnalyticsListener.self)!
            let newRelicListener = resolver.resolve(NewRelicAnalyticsListener.self)!
            return AnalyticsService(listeners: [/*mixpanelListener, */ newRelicListener])
        }.inObjectScope(.container)

//        container.register(Mixpanel.self) { resolver in
//            return Mixpanel.sharedInstance(withToken: "020cda1e8529c09118ff8b03d5d79072")
//        }.inObjectScope(.container)
//
//        container.register(MixpanelAnalyticsListener.self) { resolver in
//            let mixpanel = resolver.resolve(Mixpanel.self)!
//            return MixpanelAnalyticsListener(mixpanel: mixpanel)
//        }
        
        container.register(NewRelicAnalyticsListener.self) { resolver in
            return NewRelicAnalyticsListener()
        }
        
        // MARK: - Services
        
        container.register(Service.self) { resolver in
            let requester = resolver.resolve(ServiceRequester.self)!
            let service = Service(environment: Config.environment, requester: requester)
            service.debug = Config.debug
            return service
        }
        .initCompleted { (resolver, service) in
            let pluginProvider = resolver.resolve(ServicePluginProvider.self)!
            service.pluginProvider = pluginProvider
        }
        
        container.register(AccountProvider.self) { resolver in
            let service = resolver.resolve(Service.self)!
            let sessionStream = resolver.resolve(UserSessionStreamer.self)!
            let avatarStream = resolver.resolve(UserAvatarStreamer.self)!
            let amazoneService = resolver.resolve(AmazonService.self)!
            return AccountService(service: service, sessionStream: sessionStream, avatarStream: avatarStream, amazonService: amazoneService)
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
        
        // MARK: - Social Media Providers
        
        container.register(FacebookProvider.self) { resolver in
            let presenterProvider = resolver.resolve(PresenterProvider.self)!
            return AppFacebookProvider(presenterProvider: presenterProvider)
        }.inObjectScope(.container)
        
        container.register(GoogleProvider.self) { resolver in
            let presenterProvider = resolver.resolve(PresenterProvider.self)!
            return AppGoogleProvider(presenterProvider: presenterProvider)
        }.inObjectScope(.container)
        
        // MARK: - UIViewController Registration
        
        container.storyboardInitCompleted(UINavigationController.self) { (resolver, controller) in
            
        }

        container.storyboardInitCompleted(TabBarController.self) { (resolver, controller) in
            
        }
        
        container.storyboardInitCompleted(FinalizeAccountCreationViewController.self) { (resolver, controller) in
            let accountProvider = resolver.resolve(AccountProvider.self)!
            let bannerProvider = resolver.resolve(BannerProvider.self)!
            let overlay = resolver.resolve(ProgressOverlayProvider.self)!
            controller.inject(accountProvider: accountProvider, bannerProvider: bannerProvider, overlay: overlay)
        }
        
        container.storyboardInitCompleted(AccountViewController.self) { (resolver, controller) in
            let urlSession = resolver.resolve(URLSession.self)!
            let userStream = resolver.resolve(UserStreamer.self)!
            let avatarStream = resolver.resolve(UserAvatarStreamer.self)!
            let signInProvider = resolver.resolve(SignInProvider.self)!
            let albumProvider = resolver.resolve(PhotoAlbumProvider.self)!
            let accountProvider = resolver.resolve(AccountProvider.self)!
            let overlay = resolver.resolve(ProgressOverlayProvider.self)!
            controller.inject(urlSession: urlSession, userStream: userStream, avatarStream: avatarStream, signInProvider: signInProvider, albumProvider: albumProvider, accountProvider: accountProvider, overlay: overlay)
        }

        container.storyboardInitCompleted(ProjectFeedViewController.self) { resolver, controller in
            let theme = resolver.resolve(AppTheme.self)!
            let provider = resolver.resolve(ProjectFeedProvider.self)!
            let userStreamer = resolver.resolve(UserStreamer.self)!
            let signInProvider = resolver.resolve(SignInProvider.self)!
            let overlay = resolver.resolve(ProgressOverlayProvider.self)!
            let banner = resolver.resolve(BannerProvider.self)!
            controller.inject(theme: AnyUITheme<AppTheme>(theme: theme), provider: provider, userStreamer: userStreamer, signInProvider: signInProvider, overlay: overlay, banner: banner)
        }

        container.storyboardInitCompleted(SignInViewController.self) { resolver, controller in
            let accountProvider = resolver.resolve(AccountProvider.self)!
            let bannerProvider = resolver.resolve(BannerProvider.self)!
            let overlay = resolver.resolve(ProgressOverlayProvider.self)!
            let pageProvider = resolver.resolve(PageProvider.self)!
            let externalProvider = resolver.resolve(ExternalSignInProvider.self)!
            let facebookProvider = resolver.resolve(FacebookProvider.self)!
            let googleProvider = resolver.resolve(GoogleProvider.self)!
            controller.inject(accountProvider: accountProvider, bannerProvider: bannerProvider, overlay: overlay, pageProvider: pageProvider, externalProvider: externalProvider, facebookProvider: facebookProvider, googleProvider: googleProvider)
        }

        container.storyboardInitCompleted(LostPasswordViewController.self) { resolver, controller in
            let accountProvider = resolver.resolve(AccountProvider.self)!
            let bannerProvider = resolver.resolve(BannerProvider.self)!
            let overlay = resolver.resolve(ProgressOverlayProvider.self)!
            controller.inject(accountProvider: accountProvider, bannerProvider: bannerProvider, overlay: overlay)
        }

        container.storyboardInitCompleted(CreateAccountViewController.self) { resolver, controller in
            let accountProvider = resolver.resolve(AccountProvider.self)!
            let bannerProvider = resolver.resolve(BannerProvider.self)!
            let overlay = resolver.resolve(ProgressOverlayProvider.self)!
            controller.inject(accountProvider: accountProvider, bannerProvider: bannerProvider, overlay: overlay)
        }
        
        container.storyboardInitCompleted(ProgressOverlayViewController.self) { resolver, controller in
        }

    }
}
