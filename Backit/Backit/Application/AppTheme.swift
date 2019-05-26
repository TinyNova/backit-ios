/**
 *
 * Font names:
 *  - AcuminPro-Regular
 *  - AcuminPro-Bold
 *  - AcuminPro-Semibold
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import SwinjectStoryboard
import UIKit

class AppTheme: UIStyle {
    
    /**
     Provides a "default" `AppTheme` when the theme can not be injected at run-time (ie for embedded views).
     
     Please note: Again, this should only ever be used by embedded views. View controllers should still inject the respective theme.
     */
    static var `default`: UIThemeApplier<AppTheme> {
        return SwinjectStoryboard.defaultContainer.resolve(UIThemeApplier<AppTheme>.self)!
    }
    
    enum ButtonStyle {
        case none
    }
    
    enum ImageStyle {
        case activeAsset
        case inactiveAsset
        case playButtonOverlay
    }

    enum LabelStyle {
        case error
        case feedProjectName
        case smallInfoLabel
        case title
        case primaryButton
        case secondaryButton
    }
    
    enum TableViewStyle {
        case none
    }
    
    enum TextFieldStyle {
        // Module: UI
        case normal
    }
    
    enum TextViewStyle {
        case none
    }
    
    enum ViewStyle {
        case lineSeparator
        case gutter
    }
    
    enum ProgressViewStyle {
        case fundedPercent
    }
}

private class FontCache {
    static let `default` = FontCache()

    lazy var semibold22: UIFont = {
        return UIFont(name: "AcuminPro-Semibold", size: 22.0)!
    }()

    lazy var bold18: UIFont = {
        return UIFont(name: "AcuminPro-Bold", size: 18.0)!
    }()
    
    lazy var bold22: UIFont = {
        return UIFont(name: "AcuminPro-Bold", size: 22.0)!
    }()
    
    lazy var regular12: UIFont = {
        return UIFont(name: "AcuminPro-Regular", size: 12.0)!
    }()
    
    lazy var regular22: UIFont = {
        return UIFont(name: "AcuminPro-Regular", size: 22.0)!
    }()
}

extension AppTheme: UITheme {
    
    typealias Style = AppTheme
    
    func apply(_ styles: [ButtonStyle], toButton button: UIButton) {
    }
    
    func apply(_ styles: [LabelStyle], toLabel label: UILabel) {
        for style in styles {
            switch style {
            case .error:
                label.font = FontCache.default.regular22
                label.textColor = UIColor.fromHex(0x130a33)
            case .feedProjectName:
                label.font = FontCache.default.semibold22
                label.textColor = UIColor.fromHex(0x201c3b)
            case .smallInfoLabel:
                label.font = FontCache.default.regular12
                label.textColor = UIColor.fromHex(0x6b6c7e)
            case .title:
                label.font = FontCache.default.bold22
                label.textColor = UIColor.fromHex(0xffffff)
            case .primaryButton:
                label.font = FontCache.default.bold18
                label.textColor = UIColor.fromHex(0xffffff)
            case .secondaryButton:
                break
            }
        }
    }
    
    func apply(_ styles: [AppTheme.ImageStyle], toImage image: UIImageView) {
        for style in styles {
            switch style {
            case .activeAsset:
                image.tintColor = UIColor.fromHex(0xfd9804)
            case .inactiveAsset:
                image.tintColor = UIColor.fromHex(0xd2d2d2)
            case .playButtonOverlay:
                image.tintColor = UIColor.fromHex(0xffffff)
                image.layer.opacity = 0.5
            }
        }
    }
    
    func apply(_ styles: [TextFieldStyle], toTextField textField: UITextField) {
        styles.forEach { (style) in
            switch style {
            case .normal:
                textField.textColor = UIColor.fromHex(0xffffff)
                textField.font = FontCache.default.regular22
                textField.backgroundColor = UIColor.fromHex(0x241a50)
                textField.borderStyle = .none
            }
        }
    }
    
    func apply(_ styles: [TextViewStyle], toTextView textView: UITextView) {
    }
    
    func apply(_ styles: [TableViewStyle], toTableView tableView: UITableView) {
    }
    
    func apply(_ styles: [ViewStyle], toView view: UIView) {
        for style in styles {
            switch style {
            case .lineSeparator:
                view.backgroundColor = UIColor.fromHex(0xcdced9)
            case .gutter:
                view.backgroundColor = UIColor.fromHex(0xf5f8fa)
            }
        }
    }
    
    func apply(_ styles: [ProgressViewStyle], toProgressView progressView: UIProgressView) {
        for style in styles {
            switch style {
            case .fundedPercent:
                progressView.tintColor = UIColor.fromHex(0x00ce76)
                progressView.trackTintColor = UIColor.fromHex(0xccd6dd)
                let transform = CATransform3DScale(progressView.layer.transform, 1.0, 2.0, 1.0);
                progressView.layer.transform = transform
                progressView.layer.cornerRadius = 2.0
                progressView.layer.masksToBounds = true
            }
        }
    }
}
