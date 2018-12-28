/**
 *
 * Copyright © 2018 Backit. All rights reserved.
 */

import Foundation
import UIKit

class AppTheme: UIStyle {
    enum ButtonStyle {
        case none
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
}

extension AppTheme: UITheme {
    
    typealias Style = AppTheme
    
    func apply(_ styles: [ButtonStyle], toButton button: UIButton) {
    }
    
    func apply(_ styles: [LabelStyle], toLabel label: UILabel) {
        for style in styles {
            switch style {
            case .projectName:
                break
            case .smallComments:
                break
            case .fundedPercent:
                break
            }
        }
    }
    
    func apply(_ styles: [TextFieldStyle], toTextField textField: UITextField) {
    }
    
    func apply(_ styles: [TextViewStyle], toTextView textView: UITextView) {
    }
    
    func apply(_ styles: [TableViewStyle], toTableView tableView: UITableView) {
    }
}
