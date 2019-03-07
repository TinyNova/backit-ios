import Foundation
import UIKit

class HomepageErrorView: UIView {
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fromNib()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        fromNib()
    }
}
