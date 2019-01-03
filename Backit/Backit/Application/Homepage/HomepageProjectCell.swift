/**
 *
 * Copyright © 2018 Backit. All rights reserved.
 */

import Foundation
import SDWebImage
import SwinjectStoryboard
import UIKit

class HomepageProjectCell: UITableViewCell {
    
    @IBOutlet private weak var cardImageView: UIImageView!
    
    @IBOutlet private weak var fundedBackgroundView: UIView! {
        didSet {
            theme.apply(.defaultProgress, toView: fundedBackgroundView)
        }
    }
    
    @IBOutlet private weak var fundedForegroundView: UIView! {
        didSet {
            theme.apply(.defaultProgress, toView: fundedForegroundView)
        }
    }
    
    @IBOutlet private weak var projectNameLabel: UILabel! {
        didSet {
            theme.apply(.projectName, toLabel: projectNameLabel)
        }
    }
    
    @IBOutlet private weak var fundedPercentLabel: UILabel! {
        didSet {
            theme.apply(.fundedPercent, toLabel: fundedPercentLabel)
        }
    }
    
    @IBOutlet weak var fundedTrailing: NSLayoutConstraint! {
        didSet {
            fundedTrailing.constant = 20.0
        }
    }
    
    @IBOutlet private weak var commentsLabel: UILabel! {
        didSet {
            theme.apply(.smallComments, toLabel: commentsLabel)
        }
    }
    
    @IBOutlet private weak var imagePagerView: UIView!
    
    var theme = AppTheme.default

    func configure(project: HomepageProject) {
        projectNameLabel.text = project.name
        // FIXME: Move to view state
        switch project.source {
        case .kickstarter:
            theme.apply(.kickstarterProgressForeground, toView: fundedForegroundView)
            theme.apply(.kickstarterProgressBackground, toView: fundedBackgroundView)
        case .indiegogo:
            theme.apply(.indiegogoProgressForeground, toView: fundedForegroundView)
            theme.apply(.indiegogoProgressBackground, toView: fundedBackgroundView)
        }
        if let asset = project.assets.first, case .image(let url) = asset {
            cardImageView?.sd_setImage(with: url, placeholderImage: nil, options: [], progress: nil) { [weak self] (image, error, cacheType, imageURL) in
                self?.cardImageView?.image = self?.fittedImage(from: image, to: UIScreen.main.bounds.size.width)
            }
        }
        // FIXME: Move to view state
        switch project.comment {
        case .comment:
            commentsLabel.text = "Comment"
        case .comments(let amount):
            commentsLabel.text = "\(amount) comments"
        }
        let fundedPercent = Int(project.fundedPercent * 100)
        fundedPercentLabel.text = "\(fundedPercent)% funded"
        // Compute `fundedTrailing.constant`
        let widthOfDevice = UIScreen.main.bounds.size.width
        fundedTrailing.constant = widthOfDevice - (CGFloat(project.fundedPercent) * widthOfDevice)
    }
    
    func fittedImage(from image: UIImage?, to width: CGFloat) -> UIImage? {
        guard let image = image else {
            return nil
        }
        
        let oldWidth = image.size.width
        let scaleFactor = width / oldWidth
        
        let newHeight = image.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        image.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
