/**
 *
 * Copyright © 2018 Backit. All rights reserved.
 */

import Foundation
import SDWebImage
import SwinjectStoryboard
import UIKit

protocol HomepageProjectCellDelegate: class {
    func didTapProject(_ project: ProjectAsset)
}

class HomepageProjectCell: UITableViewCell {
    
    @IBOutlet weak var projectCardScrollView: ProjectCardScrollView! {
        didSet {
            projectCardScrollView.projectCardDelegate = self
        }
    }
    
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
    
    weak var delegate: HomepageProjectCellDelegate?
    
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
        projectCardScrollView.assets = assets
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
}

extension HomepageProjectCell: ProjectCardScrollViewDelegate {
    func didScrollToProject(_ project: ProjectAsset, at index: Int) {
        imagePagerView.selectedIndex = index
    }
    
    func didSelectProject(_ project: ProjectAsset) {
        delegate?.didTapProject(project)
    }
}
