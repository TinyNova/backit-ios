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
    
    @IBOutlet weak var imagePagerView: ImagePagerView!
    
    var theme = AppTheme.default

    func configure(project: HomepageProject) {
        projectNameLabel.text = project.name
        imagePagerView.configure(assets: project.assets, selectedIndex: 0)
        updateThemes(project.source)
        updateAssets(project.assets)
        updateComments(project.comment)
        updateFundedPercent(project.fundedPercent)
        updateFundedPercentProgress(CGFloat(project.fundedPercent))
    }
    
    private func updateThemes(_ source: ProjectSource) {
        // FIXME: Move to view state
        switch source {
        case .kickstarter:
            theme.apply(.kickstarterProgressForeground, toView: fundedForegroundView)
            theme.apply(.kickstarterProgressBackground, toView: fundedBackgroundView)
        case .indiegogo:
            theme.apply(.indiegogoProgressForeground, toView: fundedForegroundView)
            theme.apply(.indiegogoProgressBackground, toView: fundedBackgroundView)
        }
    }
    
    private func updateAssets(_ assets: [ProjectAsset]) {
        guard let asset = assets.first, case .image(let url) = asset else {
            return
        }
        
        // TODO: Update pager
        cardImageView?.sd_setImage(with: url, placeholderImage: nil, options: [], progress: nil) { [weak self] (image, error, cacheType, imageURL) in
            self?.cardImageView?.image = self?.fittedImage(from: image, to: UIScreen.main.bounds.size.width)
        }
    }
    
    private func updateComments(_ comment: ProjectComment) {
        // FIXME: Move to view state
        // TODO: Use i18n (or move to view state)
        switch comment {
        case .comment:
            commentsLabel.text = "Comment"
        case .comments(let amount):
            commentsLabel.text = "\(amount) comments"
        }
    }
    
    private func updateFundedPercent(_ fundedPercent: Float) {
        let fundedPercent = Int(fundedPercent * 100)
        // TODO: Use i18n (or move to view state)
        fundedPercentLabel.text = "\(fundedPercent)% funded"
    }
    
    private func updateFundedPercentProgress(_ fundedPercent: CGFloat) {
        let widthOfDevice = UIScreen.main.bounds.size.width
        fundedTrailing.constant = widthOfDevice - (fundedPercent * widthOfDevice)
    }
    
    private func fittedImage(from image: UIImage?, to width: CGFloat) -> UIImage? {
        guard let image = image else {
            return nil
        }
        
        let oldWidth = image.size.width
        let scaleFactor = width / oldWidth
        
        let newHeight = image.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        let size = CGSize(width: newWidth, height: newHeight)
        // NOTE: Make sure this is using the more efficient version of drawing images.
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        image.draw(in: CGRect(x:0, y:0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
