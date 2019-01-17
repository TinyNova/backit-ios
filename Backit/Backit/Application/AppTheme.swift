/**
 *
 * Copyright © 2018 Backit. All rights reserved.
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
        case projectName
        case smallComments
        case fundedPercent
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
        // Progress bars
        case defaultProgress
        case kickstarterProgressForeground
        case kickstarterProgressBackground
        case indiegogoProgressForeground
        case indiegogoProgressBackground
    }
}

extension AppTheme: UITheme {

    typealias Style = AppTheme
    
    func apply(_ styles: [ButtonStyle], toButton button: UIButton) {
    }
    
    func apply(_ styles: [LabelStyle], toLabel label: UILabel) {
        for style in styles {
            switch style {
            case .projectName:
                let font = UIFont(name: "lato-bold", size: 20.0)
                label.font = font
                label.textColor = UIColor.fromHex(0x404040)
            case .smallComments:
                let font = UIFont(name: "lato-black", size: 12.0)
                label.font = font
                label.textColor = UIColor.fromHex(0x000000)
            case .fundedPercent:
                let font = UIFont(name: "lato-black", size: 16.0)
                label.font = font
                label.textColor = UIColor.fromHex(0x000000)
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
        for style in styles {
            switch style {
            case .defaultProgress:
                view.backgroundColor = UIColor.white
            case .kickstarterProgressForeground:
                view.backgroundColor = UIColor.fromHex(0x39dd74)
            case .kickstarterProgressBackground:
                view.backgroundColor = UIColor.fromHex(0xcdffde)
            case .indiegogoProgressForeground:
                view.backgroundColor = UIColor.fromHex(0xe91578)
            case .indiegogoProgressBackground:
                view.backgroundColor = UIColor.fromHex(0xfbcae1)
            }
        }
    }
}
