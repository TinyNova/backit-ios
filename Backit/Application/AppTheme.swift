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
        case informationalHeader
        case feedProjectName
        case smallInfo
        case info
        case blurb
        case title
        case primaryButton
        case secondaryButton
        case textButton
        case underlineButton
        case underline
        case loginHeader
    }
    
    enum TableViewStyle {
        case none
    }
    
    enum TextFieldStyle {
        // Module: UI
        case normal
    }
    
    enum TextViewStyle {
        case informational
        case link(needle: String, href: String)
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

    lazy var bold16: UIFont = {
        return UIFont(name: "AcuminPro-Bold", size: 16.0)!
    }()
    
    lazy var bold22: UIFont = {
        return UIFont(name: "AcuminPro-Bold", size: 22.0)!
    }()
    
    lazy var regular12: UIFont = {
        return UIFont(name: "AcuminPro-Regular", size: 12.0)!
    }()

    lazy var regular16: UIFont = {
        return UIFont(name: "AcuminPro-Regular", size: 16.0)!
    }()

    lazy var regular18: UIFont = {
        return UIFont(name: "AcuminPro-Regular", size: 18.0)!
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
                label.font = FontCache.default.regular18
                label.textColor = UIColor.fromHex(0xd45f47)
                label.numberOfLines = 0
            case .informationalHeader:
                label.font = FontCache.default.regular18
                label.textColor = UIColor.fromHex(0x000000)
            case .feedProjectName:
                label.font = FontCache.default.semibold22
                label.textColor = UIColor.fromHex(0x201c3b)
            case .smallInfo:
                label.font = FontCache.default.regular12
                label.textColor = UIColor.fromHex(0x6b6c7e)
            case .info:
                label.font = FontCache.default.regular16
                label.textColor = UIColor.fromHex(0xffffff)
                label.numberOfLines = 0
            case .blurb:
                label.font = FontCache.default.regular12
                label.textColor = UIColor.fromHex(0x000000)
                label.numberOfLines = 0
            case .title:
                label.font = FontCache.default.regular18
                label.textColor = UIColor.fromHex(0xcdced9)
            case .primaryButton:
                label.font = FontCache.default.bold16
                label.textColor = UIColor.fromHex(0xffffff)
            case .secondaryButton:
                label.font = FontCache.default.bold16
                label.textColor = UIColor.fromHex(0xffffff)
            case .textButton:
                label.font = FontCache.default.bold16
                label.textColor = UIColor.fromHex(0xffffff)
            case .underline:
                guard let text = label.text else {
                    return
                }
                let range = NSMakeRange(0, text.count)
                let attrText = NSMutableAttributedString(string: text)
                attrText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
                label.attributedText = attrText
            case .underlineButton:
                label.font = FontCache.default.bold16
                label.textColor = UIColor.fromHex(0xffffff)
            case .loginHeader:
                label.font = FontCache.default.bold22
                label.textColor = UIColor.fromHex(0xffffff)
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
        styles.forEach { (style) in
            switch style {
            case .informational:
                guard let text = textView.text else {
                    return
                }

                textView.backgroundColor = UIColor.clear
                textView.isEditable = false
                textView.isScrollEnabled = false
                textView.dataDetectorTypes = .link

                let attrString = NSMutableAttributedString(string: text)
                let paragraph = NSMutableParagraphStyle()
                paragraph.lineSpacing = 8.0
                paragraph.alignment = .center
                let fullRange = NSMakeRange(0, text.count)
                attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraph, range: fullRange)
                attrString.addAttribute(.font, value: FontCache.default.regular18, range: fullRange)
                attrString.addAttribute(.foregroundColor, value: UIColor.fromHex(0xffffff), range: fullRange)
                textView.attributedText = attrString
            case .link(let needle, let href):
                guard let text = textView.text, let attrText = textView.attributedText else {
                    return
                }
                let attrString = NSMutableAttributedString(attributedString: attrText)
                let nsString = NSString(string: text)
                let range = nsString.range(of: needle)
                attrString.addAttribute(.link, value: href, range: range)
                attrString.addAttribute(.foregroundColor, value: UIColor(red: 27.0 / 255.0, green: 150.0 / 255.0, blue: 241.0 / 255.0, alpha: 1.0), range: range)
                textView.attributedText = attrString
            }
        }
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
