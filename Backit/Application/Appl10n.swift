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
    case earlyBirds(amount: Int)
    case daysLeft(amount: Int)
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
    case field(AccountValidationField)
    case firstName
    case lastName
    case refreshToken
    case unknownField
    case byAuthor(String)
    case readCampaignDescription
}

extension Appl10n: LocalizationType {
    func localize() -> String {
        switch self {
        case .comment:
            return l(key: "comment")
        case .comments(let amount):
            return l(key: "comments(amount)", arguments: number(amount))
        case .earlyBirds(let amount):
            return l(key: "earlyBirds(amount)", arguments: number(amount))
        case .daysLeft(let amount):
            return l(key: "daysLeft(amount)", arguments: number(amount))
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
        case .field(let field):
            switch field {
            case .email:
                return Appl10n.email.localize()
            case .firstName:
                return Appl10n.firstName.localize()
            case .lastName:
                return Appl10n.lastName.localize()
            case .password:
                return Appl10n.password.localize()
            case .username:
                return Appl10n.username.localize()
            case .refreshToken:
                return Appl10n.refreshToken.localize()
            case .unknown:
                return Appl10n.unknownField.localize()
            }
        case .firstName:
            return l(key: "firstName")
        case .lastName:
            return l(key: "lastName")
        case .refreshToken:
            return l(key: "refreshToken")
        case .unknownField:
            return l(key: "unknownField")
        case .byAuthor(let name):
            return l(key: "byAuthor(name)", arguments: name)
        case .readCampaignDescription:
            return l(key: "readCampaignDescription")
        }
    }
}
