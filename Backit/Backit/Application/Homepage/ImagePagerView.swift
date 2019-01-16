/**
 *
 * Copyright © 2018 Backit. All rights reserved.
 */

import Foundation
import UIKit

class ImagePagerView: UIView {
    
    @IBOutlet weak var stackView: UIStackView!
    
    var selectedIndex: Int = 0 {
        didSet {
            for (index, view) in stackView.arrangedSubviews.enumerated() {
                guard let imageView = view as? UIImageView else {
                    continue
                }
                
                let selected = index == selectedIndex
                if selected {
                    theme.apply(.activeAsset, toImage: imageView)
                }
                else {
                    theme.apply(.inactiveAsset, toImage: imageView)
                }
            }
        }
    }
    
    private var theme: UIThemeApplier<AppTheme> = AppTheme.default
    
    override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        guard subviews.isEmpty else {
            return self
        }
        
        let nib = Bundle.main.loadNibNamed("ImagePagerView", owner: nil, options: nil)?.first as? UIView
        nib?.frame = self.frame
        nib?.autoresizingMask = self.autoresizingMask
        nib?.alpha = self.alpha
        nib?.translatesAutoresizingMaskIntoConstraints = self.translatesAutoresizingMaskIntoConstraints
        return nib
    }
    
    func inject(theme: UIThemeApplier<AppTheme>) {
        self.theme = theme
    }
    
    func configure(assets: [ProjectAsset], selectedIndex: Int) {
        stackView.removeAllArrangedSubviews()
        
        for asset in assets {
            let image: UIImage?
            switch asset {
            case .image:
                // FIXME: Use a library
                image = UIImage(named: "carousel-dot")
            case .video:
                image = UIImage(named: "carousel-play")
            }
            let imageView = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
            stackView.addArrangedSubview(imageView)
            stackView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 10.0))
        }
        
        self.selectedIndex = selectedIndex
    }
}
