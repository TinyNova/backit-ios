/**
 Provides interface to apply styles.
 
 TODO:
   - Simplify this even more by creating a `Style` with only one `associatedvalue`.
   - This way the app doesn't need to implement a style for every UI type. This should make it easy to support any UI type.
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Foundation
import UIKit

protocol UIStyle {
    associatedtype ButtonStyle
    associatedtype ImageStyle
    associatedtype LabelStyle
    associatedtype TableViewStyle
    associatedtype TextFieldStyle
    associatedtype TextViewStyle
    associatedtype ViewStyle
    associatedtype ProgressViewStyle
}

protocol UITheme {
    associatedtype Style: UIStyle
    
    func apply(_ styles: [Style.ButtonStyle], toButton button: UIButton)
    func apply(_ styles: [Style.ImageStyle], toImage image: UIImageView)
    func apply(_ styles: [Style.LabelStyle], toLabel label: UILabel)
    func apply(_ styles: [Style.TableViewStyle], toTableView tableView: UITableView)
    func apply(_ styles: [Style.TextFieldStyle], toTextField textField: UITextField)
    func apply(_ styles: [Style.TextViewStyle], toTextView textView: UITextView)
    func apply(_ styles: [Style.ViewStyle], toView view: UIView)
    func apply(_ styles: [Style.ProgressViewStyle], toProgressView progressView: UIProgressView)
}
