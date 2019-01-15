import Foundation
import UIKit

extension UIStackView {
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach { (view) in
            removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}
