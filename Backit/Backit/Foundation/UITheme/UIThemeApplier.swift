/**
 Provides reconciliation when either `IBOutlet` or the `UITheme` do not yet exist. This is achieved by caching the applied `UIStyle`s and applying them when possible.
 
 This also provides a more simple interface to the `UITheme` protocol. The `UITheme.apply*` methods accept an array. This class takes a variadic of `UIStyle`s, which reads much better.
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Foundation
import UIKit

class UIThemeApplier<T: UIStyle> {
    
    var buttonThemes: [([T.ButtonStyle], UIButton)] = []
    var imageThemes: [([T.ImageStyle], UIImageView)] = []
    var labelThemes: [([T.LabelStyle], UILabel)] = []
    var tableViewThemes: [([T.TableViewStyle], UITableView)] = []
    var textFieldThemes: [([T.TextFieldStyle], UITextField)] = []
    var textViewThemes: [([T.TextViewStyle], UITextView)] = []
    var viewThemes: [([T.ViewStyle], UIView)] = []
    
    var concrete: AnyUITheme<T>? {
        didSet {
            guard let concrete = concrete else {
                return
            }
            
            buttonThemes.forEach { (element) in
                concrete.apply(element.0, toButton: element.1)
            }
            buttonThemes = []
            
            labelThemes.forEach { (element) in
                concrete.apply(element.0, toLabel: element.1)
            }
            labelThemes = []
            
            tableViewThemes.forEach { (element) in
                concrete.apply(element.0, toTableView: element.1)
            }
            tableViewThemes = []

            textFieldThemes.forEach { (element) in
                concrete.apply(element.0, toTextField: element.1)
            }
            textFieldThemes = []

            textViewThemes.forEach { (element) in
                concrete.apply(element.0, toTextView: element.1)
            }
            textViewThemes = []
            
            viewThemes.forEach { (element) in
                concrete.apply(element.0, toView: element.1)
            }
            viewThemes = []
        }
    }
    
    func apply(_ styles: T.ButtonStyle..., toButton button: UIButton) {
        guard let theme = concrete else {
            buttonThemes.append((styles, button))
            return
        }
        theme.apply(styles, toButton: button)
    }
    
    func apply(_ styles: T.ImageStyle..., toImage image: UIImageView) {
        guard let theme = concrete else {
            imageThemes.append((styles, image))
            return
        }
        theme.apply(styles, toImage: image)
    }

    
    func apply(_ styles: T.LabelStyle..., toLabel label: UILabel) {
        guard let theme = concrete else {
            labelThemes.append((styles, label))
            return
        }
        theme.apply(styles, toLabel: label)
    }
    
    func apply(_ styles: T.TableViewStyle..., toTableView tableView: UITableView) {
        guard let theme = concrete else {
            tableViewThemes.append((styles, tableView))
            return
        }
        theme.apply(styles, toTableView: tableView)
    }
    
    func apply(_ styles: T.TextFieldStyle..., toTextField textField: UITextField) {
        guard let theme = concrete else {
            textFieldThemes.append((styles, textField))
            return
        }
        theme.apply(styles, toTextField: textField)
    }
    
    func apply(_ styles: T.TextViewStyle..., toTextView textView: UITextView) {
        guard let theme = concrete else {
            textViewThemes.append((styles, textView))
            return
        }
        theme.apply(styles, toTextView: textView)
    }
    
    func apply(_ styles: T.ViewStyle..., toView view: UIView) {
        guard let theme = concrete else {
            viewThemes.append((styles, view))
            return
        }
        theme.apply(styles, toView: view)
    }

}
