/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

class AppPageProvider: PageProvider {
    
    func finalizeAccountCreation() -> FinalizeAccountCreationViewController? {
        let storyboard = UIStoryboard(name: "FinalizeAccountCreationViewController", bundle: Bundle(for: FinalizeAccountCreationViewController.self))
        guard let vc = storyboard.instantiateInitialViewController() as? FinalizeAccountCreationViewController else {
            log.c("Failed to inflate `FinalizeAccountCreationViewController`")
            return nil
        }

        return vc
    }
    
    func lostPassword() -> LostPasswordViewController? {
        let storyboard = UIStoryboard(name: "LostPasswordViewController", bundle: Bundle(for: LostPasswordViewController.self))
        guard let vc = storyboard.instantiateInitialViewController() as? LostPasswordViewController else {
            log.c("Failed to inflate `LostPasswordViewController`")
            return nil
        }

        return vc
    }
    
    func createAccount() -> CreateAccountViewController? {
        let storyboard = UIStoryboard(name: "CreateAccountViewController", bundle: Bundle(for: CreateAccountViewController.self))
        guard let vc = storyboard.instantiateInitialViewController() as? CreateAccountViewController else {
            log.c("Failed to inflate `CreateAccountViewController`")
            return nil
        }

        return vc
    }
    
    func signIn() -> UINavigationController? {
        let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle(for: AppSignInProvider.self))
        guard let vc = storyboard.instantiateInitialViewController() as? UINavigationController else {
            log.c("Failed to inflate `UINavigationController` for SignIn")
            return nil
        }

        return vc
    }
    
    func progressOverlay() -> ProgressOverlayViewController? {
        let storyboard = UIStoryboard(name: "ProgressOverlayViewController", bundle: Bundle(for: ProgressOverlayViewController.self))
        guard let vc = storyboard.instantiateInitialViewController() as? ProgressOverlayViewController else {
            log.c("Failed to inflate `ProgressOverlayViewController`")
            return nil
        }
        
        return vc
    }
    
    func projectDetails() -> ProjectDetailsViewController? {
        let storyboard = UIStoryboard(name: "ProjectDetailsViewController", bundle: Bundle(for: ProjectDetailsViewController.self))
        guard let vc = storyboard.instantiateInitialViewController() as? ProjectDetailsViewController else {
            log.c("Failed to inflate `ProjectDetailsViewController`")
            return nil
        }
        
        return vc
    }
    
    func projectDescription() -> UINavigationController? {
        let storyboard = UIStoryboard(name: "ProjectDescriptionViewController", bundle: Bundle(for: ProjectDescriptionViewController.self))
        guard let vc = storyboard.instantiateInitialViewController() as? UINavigationController else {
            log.c("Failed to inflate `ProjectDetailsViewController`")
            return nil
        }
        
        return vc
    }

}
