/**
 *
 * https://www.raywenderlich.com/250-internationalizing-your-ios-app-getting-started
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */


import Foundation

enum Appl10n {
    case comment
    case comments(amount: Int)
    case funded(amount: Int)
    case loadingProjects
    case loginToBackit
    case youreUpToDate
    case errorLoadingProjects
    case `continue`
    case forgotYourPassword
    case recoverPassword
    case loginWithFacebook
    case loginWithGoogle
    case signUpForAccount
    case createAccount
    case createAnAccount
    case email
    case username
    case password
    case byContinuingYouAgree
    case termsOfService
    case privacyPolicy
    case mustHaveProvidedEmail
    case resetPassword
    case passwordSuccessfullyReset
    case finalizeCreatingYourAccount
}

extension Appl10n: LocalizationType {
    func localize() -> String {
        switch self {
        case .comment:
            return l(key: "comment")
        case .comments(let amount):
            return l(key: "comments(amount)", arguments: number(amount))
        case .funded(let amount):
            return l(key: "funded", arguments: number(amount))
        case .loadingProjects:
            return l(key: "loadingProjects")
        case .loginToBackit:
            return l(key: "loginToBackit")
        case .youreUpToDate:
            return l(key: "youreUpToDate")
        case .errorLoadingProjects:
            return l(key: "errorLoadingProjects")
        case .continue:
            return l(key: "continue")
        case .forgotYourPassword:
            return l(key: "forgotYourPassword")
        case .recoverPassword:
            return l(key: "recoverPassword")
        case .loginWithFacebook:
            return l(key: "loginWithFacebook")
        case .loginWithGoogle:
            return l(key: "loginWithGoogle")
        case .signUpForAccount:
            return l(key: "signUpForAccount")
        case .createAccount:
            return l(key: "createAccount")
        case .createAnAccount:
            return l(key: "createAnAccount")
        case .email:
            return l(key: "email")
        case .username:
            return l(key: "username")
        case .password:
            return l(key: "password")
        case .byContinuingYouAgree:
            return l(key: "byContinuingYouAgree")
        case .termsOfService:
            return l(key: "termsOfService")
        case .privacyPolicy:
            return l(key: "privacyPolicy")
        case .mustHaveProvidedEmail:
            return l(key: "mustHaveProvidedEmail")
        case .resetPassword:
            return l(key: "resetPassword")
        case .passwordSuccessfullyReset:
            return l(key: "passwordSuccessfullyReset")
        case .finalizeCreatingYourAccount:
            return l(key: "finalizeCreatingYourAccount")
        }
    }
}
