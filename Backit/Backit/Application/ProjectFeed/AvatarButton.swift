import Foundation
import UIKit

class AvatarButton: UIView {
    
    @IBOutlet private weak var imageView: UIImageView! {
        didSet {
            imageView.layer.cornerRadius = 2.0
        }
    }

    var imageURL: URL? {
        didSet {
            imageView.sd_setImage(with: imageURL, completed: nil)
        }
    }
}
