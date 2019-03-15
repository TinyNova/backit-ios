import Foundation
import UIKit

protocol HomepageErrorViewDelegate: class {
    func didRequestToReloadData()
}

class HomepageErrorView: UIView {
    
    @IBOutlet weak var errorMessageLabel: UILabel!

    weak var delegate: HomepageErrorViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        configure()
    }
    
    private func configure() {
        fromNib()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        addGestureRecognizer(gesture)
    }
    
    @objc private func didTapView(sender: UITapGestureRecognizer) {
        delegate?.didRequestToReloadData()
    }
}
