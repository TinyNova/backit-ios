import Foundation
import UIKit

public class CenteredImageView: UIView {
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.backgroundColor = .clear
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    private func setup() {
        guard let view = fromNib() else {
            return
        }
        self.backgroundColor = .clear
        view.backgroundColor = .clear
    }
    
    public func configure(image: UIImage?, size: CGFloat) {
        self.widthConstraint.constant = size
        self.heightConstraint.constant = size
        self.imageView.image = image?.fittedImage(to: size)
    }
}
