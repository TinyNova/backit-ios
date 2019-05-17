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
        case feedProjectName
        case smallInfoLabel
    }
    
    enum TableViewStyle {
        case none
    }
    
    enum TextFieldStyle {
        case none
    }
    
    enum TextViewStyle {
        case none
    }
    
    enum ViewStyle {
        case lineSeparator
        case gutter
    }
}

private class FontCache {
    static let `default` = FontCache()

    lazy var semibold22: UIFont = {
        return UIFont(name: "AcuminPro-Semibold", size: 22.0)!
    }()

    lazy var regular12: UIFont = {
        return UIFont(name: "AcuminPro-Bold", size: 12.0)!
    }()
}

extension AppTheme: UITheme {

    typealias Style = AppTheme
    
    func apply(_ styles: [ButtonStyle], toButton button: UIButton) {
    }
    
    func apply(_ styles: [LabelStyle], toLabel label: UILabel) {
        for style in styles {
            switch style {
            case .feedProjectName:
                label.font = FontCache.default.semibold22
                label.textColor = UIColor.fromHex(0x201c3b)
            case .smallInfoLabel:
                label.font = FontCache.default.regular12
                label.textColor = UIColor.fromHex(0x6b6c7e)
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
    }
    
    func apply(_ styles: [TextViewStyle], toTextView textView: UITextView) {
    }
    
    func apply(_ styles: [TableViewStyle], toTableView tableView: UITableView) {
    }
    
    func apply(_ styles: [ViewStyle], toView view: UIView) {
    }
}
