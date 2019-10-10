/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import BrightFutures
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

    static let AppStartPromise = "AppInitializePromise"

    let container: Container = SwinjectStoryboard.defaultContainer
    
    init() {
        container.register(DispatchQueue.self) { _ in
            return DispatchQueue.main
        }
        
        container.register(URLSession.self) { _ in
            return URLSession(configuration: URLSessionConfiguration.default)
        }

        container.register(Promise<IgnorableValue, NoError>.self, name: Assembly.AppStartPromise) { resolver in
            return Promise<IgnorableValue, NoError>()
        }
        .inObjectScope(.container)

        container.register(ServiceRequester.self) { resolver in
            let promise = resolver.resolve(Promise<IgnorableValue, NoError>.self, name: Assembly.AppStartPromise)!

            let exclude: [EndpointKey] = [
                RefreshTokenEndpoint.key
            ]

            if Config.environment == .dev {
                let sessionManager = AlamofireSessionManagerFactory.makeDevelopment()
                return AlamofireServiceRequester(sessionManager: sessionManager, start: promise.future, exclude: exclude)
            }
            
            let sessionManager = AlamofireSessionManagerFactory.makeProduction()
            return AlamofireServiceRequester(sessionManager: sessionManager, start: promise.future, exclude: exclude)
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
        
        container.register(KeychainProvider.self) { resolver in
            let dispatchQueue = resolver.resolve(DispatchQueue.self)!
            return AppKeychainProvider(dispatchQueue: dispatchQueue)
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
            let accountProvider = resolver.resolve(AccountProvider.self)!
            let pageProvider = resolver.resolve(PageProvider.self)!
            return AppExternalSignInProvider(accountProvider: accountProvider, pageProvider: pageProvider)
        }
        .inObjectScope(.container)
        
        container.register(AmazonService.self) { resolver in
            let urlSession = resolver.resolve(URLSession.self)!
            return AmazonService(urlSession: urlSession)
        }
        
        container.register(PresenterProvider.self) { resolver in
            return AppPresenterProvider()
        }
        
        container.register(ShareProvider.self) { resolver in
            let presenterProvider = resolver.resolve(PresenterProvider.self)!
            return AppShareProvider(presenterProvider: presenterProvider)
        }
        
        container.register(BannerMessageProvider.self) { resolver in
            return AppBannerMessageProvider()
        }
        
        container.register(BannerProvider.self) { resolver in
            let messageProvider = resolver.resolve(BannerMessageProvider.self)!
            return AppBannerProvider(messageProvider: messageProvider)
        }.inObjectScope(.container)
        
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
        
        container.register(DatabaseProvider.self) { resolver in
            return AppDatabaseProvider()
        }
        
        container.register(ProjectVoteProvider.self) { resolver in
            let database = resolver.resolve(DatabaseProvider.self)!
            let projectProvider = resolver.resolve(ProjectProvider.self)!
            let userStream = resolver.resolve(UserStreamer.self)!
            return ProjectVoteService(database: database, projectProvider: projectProvider, userStream: userStream)
        }
        
        container.register(ProjectFeedCompositionProvider.self) { resolver in
            let discussionProvider = resolver.resolve(DiscussionProvider.self)!
            let voteProvider = resolver.resolve(ProjectVoteProvider.self)!
            return ProjectFeedCompositionService(discussionProvider: discussionProvider, voteProvider: voteProvider)
        }
        
        container.register(ProjectFeedProvider.self) { resolver in
            let service = resolver.resolve(AnalyticsService.self)!
            let metrics: AnalyticsPublisher<MetricAnalyticsEvent> = service.publisher()
            let userStream = resolver.resolve(UserStreamer.self)!

            let projectProvider = resolver.resolve(ProjectProvider.self)!
            let projectComposition = resolver.resolve(ProjectFeedCompositionProvider.self)!
            let voteProvider = resolver.resolve(ProjectVoteProvider.self)!
            return ProjectFeedService(projectProvider: projectProvider, projectComposition: projectComposition, metrics: metrics, userStream: userStream, voteProvider: voteProvider)
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
        
        container.register(DiscussionProvider.self) { resolver in
            let service = resolver.resolve(Service.self)!
            return DiscussionService(service: service)
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
        
        container.register(ProjectSearchProvider.self) { _ in
            return ProjectSearchService()
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
            let urlSession = resolver.resolve(URLSession.self)!
            let accountProvider = resolver.resolve(AccountProvider.self)!
            let bannerProvider = resolver.resolve(BannerProvider.self)!
            let overlay = resolver.resolve(ProgressOverlayProvider.self)!
            controller.inject(urlSession: urlSession, accountProvider: accountProvider, bannerProvider: bannerProvider, overlay: overlay)
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
            let pageProvider = resolver.resolve(PageProvider.self)!
            let projectProvider = resolver.resolve(ProjectProvider.self)!
            let provider = resolver.resolve(ProjectFeedProvider.self)!
            let signInProvider = resolver.resolve(SignInProvider.self)!
            let overlay = resolver.resolve(ProgressOverlayProvider.self)!
            let banner = resolver.resolve(BannerProvider.self)!
            let shareProvider = resolver.resolve(ShareProvider.self)!
            controller.inject(theme: AnyUITheme<AppTheme>(theme: theme), pageProvider: pageProvider, projectProvider: projectProvider, provider: provider, signInProvider: signInProvider, overlay: overlay, banner: banner, shareProvider: shareProvider)
        }
        
        container.storyboardInitCompleted(ProjectDetailsViewController.self) { resolver, controller in
            let pageProvider = resolver.resolve(PageProvider.self)!
            controller.inject(pageProvider: pageProvider)
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
        
        container.storyboardInitCompleted(ProjectDescriptionViewController.self) { resolver, controller in
        }
        
        container.storyboardInitCompleted(SearchViewController.self) { resolver, controller in
            let searchProvider = resolver.resolve(ProjectSearchProvider.self)!
            controller.inject(searchProvider: searchProvider)
        }
    }
}
