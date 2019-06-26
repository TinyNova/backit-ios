/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

protocol ProjectTableViewCellDelegate: class {
    func didTapProject(_ project: FeedProject)
    func didTapAsset(_ asset: ProjectAsset)
    func didTapComments(_ project: FeedProject)
}

class ProjectTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var favoriteImageView: UIImageView!
    
    @IBOutlet private weak var imagePagerView: ImagePagerView!
    
    @IBOutlet private weak var projectImageCollectionView: ProjectImageCollectionView! {
        didSet {
            projectImageCollectionView.projectDelegate = self
        }
    }
    @IBOutlet private weak var collectionViewHeightConstraint: NSLayoutConstraint! {
        didSet {
            collectionViewHeightConstraint.constant = ProjectImageSize.height
        }
    }
    
    @IBOutlet private weak var projectNameLabel: UILabel! {
        didSet {
            theme.apply(.feedProjectName, toLabel: projectNameLabel)
        }
    }
    
    @IBOutlet private weak var fundedPercentProgressView: UIProgressView! {
        didSet {
            theme.apply(.fundedPercent, toProgressView: fundedPercentProgressView)
        }
    }
    
    @IBOutlet private weak var percentFundedLabel: UILabel! {
        didSet {
            theme.apply(.smallInfo, toLabel: percentFundedLabel)
        }
    }
    
    @IBOutlet private weak var earlyBirdLabel: UILabel! {
        didSet {
            theme.apply(.smallInfo, toLabel: earlyBirdLabel)
        }
    }
    
    @IBOutlet private weak var daysLeftLabel: UILabel! {
        didSet {
            theme.apply(.smallInfo, toLabel: daysLeftLabel)
        }
    }
    
    @IBOutlet private weak var separatorView: UIView! {
        didSet {
            theme.apply(.lineSeparator, toView: separatorView)
        }
    }
    
    @IBOutlet private weak var totalVotesView: UIView! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapUpVote(gesture:)))
            totalVotesView.addGestureRecognizer(tapGesture)
        }
    }
    @IBOutlet private weak var totalVotesImage: UIImageView! {
        didSet {
            totalVotesImage.tintColor = UIColor.fromHex(0x657786)
        }
    }
    @IBOutlet private weak var totalVotesLabel: UILabel! {
        didSet {
            theme.apply(.smallInfo, toLabel: totalVotesLabel)
        }
    }
    
    @IBOutlet private weak var totalCommentsView: UIView! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapComments(gesture:)))
            totalCommentsView.addGestureRecognizer(tapGesture)
        }
    }
    @IBOutlet private weak var totalCommentsImage: UIImageView! {
        didSet {
            totalCommentsImage.tintColor = UIColor.fromHex(0x657786)
        }
    }
    @IBOutlet private weak var totalCommentsLabel: UILabel! {
        didSet {
            theme.apply(.smallInfo, toLabel: totalCommentsLabel)
        }
    }
    
    @IBOutlet private weak var shareView: UIView! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapShare(gesture:)))
            shareView.addGestureRecognizer(tapGesture)
        }
    }
    @IBOutlet private weak var shareImage: UIImageView! {
        didSet {
            shareImage.tintColor = UIColor.fromHex(0x657786)
        }
    }
    @IBOutlet private weak var shareLabel: UILabel! {
        didSet {
            theme.apply(.smallInfo, toLabel: shareLabel)
        }
    }
    
    @IBOutlet private weak var bottomSpacerView: UIView! {
        didSet {
            theme.apply(.gutter, toView: bottomSpacerView)
        }
    }
    
    weak var delegate: ProjectTableViewCellDelegate?
    
    private let theme: UIThemeApplier<AppTheme> = AppTheme.default
    private let i18n = Localization<Appl10n>()
    
    private(set) var project: FeedProject? {
        didSet {
            guard let project = project else {
                return
            }
            
            projectImageCollectionView.assets = project.assets
            imagePagerView.configure(assets: project.assets, selectedIndex: 0)
            
            projectNameLabel.text = project.name
            
            fundedPercentProgressView.progress = project.fundedPercent
            
            let fundedPercent = Int(project.fundedPercent * 100)
            percentFundedLabel.text = i18n.t(.funded(amount: fundedPercent))
            earlyBirdLabel.text = "XX early birds"
            daysLeftLabel.text = "XX days left"
            
            totalVotesLabel.text = "XX.XXk"
            switch project.comment {
            case .comment:
                totalCommentsLabel.text = i18n.t(.comment)
            case .comments(let amount):
                totalCommentsLabel.text = i18n.t(.comments(amount: amount))
            }
        }
    }
    
    func configure(with project: FeedProject) {
        self.project = project
    }
    
    // MARK: Private functions
    
    @objc private func didTapShare(gesture: UITapGestureRecognizer) {
        log.i("did tap share")
    }
    
    @objc private func didTapComments(gesture: UITapGestureRecognizer) {
        log.i("did tap comment")
    }
    
    @objc private func didTapUpVote(gesture: UITapGestureRecognizer) {
        log.i("did tap up vote")
    }
}

extension ProjectTableViewCell: ProjectImageCollectionViewDelegate {
    func didSelectProjectAsset(_ asset: ProjectAsset) {
        log.i("did select asset: \(asset)")
    }
    
    func didScrollToProjectAsset(_ asset: ProjectAsset, at index: Int) {
        log.i("Did scroll to asset: \(asset)")
    }
}
