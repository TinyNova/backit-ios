/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

protocol PageProvider {
    func finalizeAccountCreation() -> FinalizeAccountCreationViewController?
    func lostPassword() -> LostPasswordViewController?
    func createAccount() -> CreateAccountViewController?
    func signIn() -> UINavigationController?
    func progressOverlay() -> ProgressOverlayViewController?
    func projectDetails() -> ProjectDetailsViewController?
    func projectDescription() -> UINavigationController?
}
