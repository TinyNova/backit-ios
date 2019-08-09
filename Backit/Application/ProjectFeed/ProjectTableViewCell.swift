/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

enum VoteAction {
    case add
    case remove
}

protocol ProjectTableViewCellDelegate: class {
    func didTapProjectCell(_ cell: ProjectTableViewCell)
    func didTapAsset(_ asset: ProjectAsset)
    func didTapComments(_ project: FeedProject)
    func didTapShare(_ project: FeedProject, from view: UIView)
    func didTapVote(_ project: FeedProject, action: VoteAction)
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
            theme.apply(.smallProjectName, toLabel: projectNameLabel)
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
    private var didVote: Bool = false
    private var voteCount: Int = 0
    
    private(set) var project: FeedProject? {
        didSet {
            guard let project = project else {
                return
            }
            
            projectImageCollectionView.hero.id = ProjectFeedModule.HeroId.projectImage(project.id)
            projectNameLabel.hero.id = ProjectFeedModule.HeroId.projectName(project.id)

            projectImageCollectionView.assets = project.assets
            imagePagerView.configure(assets: project.assets, selectedIndex: 0)
            
            projectNameLabel.text = project.name
            
            fundedPercentProgressView.progress = project.fundedPercent
            
            let fundedPercent = Int(project.fundedPercent * 100)
            percentFundedLabel.text = i18n.t(.funded(amount: fundedPercent))
            earlyBirdLabel.text = i18n.t(.earlyBirds(amount: project.numEarlyBirdRewards))
            daysLeftLabel.text = i18n.t(.daysLeft(amount: project.numDaysLeft))
            
            // TODO: condense > 1k `XX.XXk`
            totalVotesLabel.text = String(project.numVotes)
            switch project.comment {
            case .comment:
                totalCommentsLabel.text = i18n.t(.comment)
            case .comments(let amount):
                totalCommentsLabel.text = i18n.t(.comments(amount: amount))
            }
            
            project.commentCount
                .onComplete { [weak self] (result) in
                    guard let count = result.value, count > 0 else {
                        return
                    }
                    self?.totalCommentsLabel.text = self?.i18n.t(.comments(amount: count))
                }
            
            project.voted
                .onSuccess { [weak self] (didVote) in
                    self?.didVote = didVote
                    let color: UIColor = didVote ? UIColor.fromHex(0x130a33) : UIColor.fromHex(0x657786)
                    self?.totalVotesImage.tintColor = color
                }
        }
    }
    
    func configure(with project: FeedProject) {
        self.project = project
    }
    
    // MARK: Private functions
    
    @objc private func didTapShare(gesture: UITapGestureRecognizer) {
        guard let project = project else {
            return log.c(notConfigured())
        }
        delegate?.didTapShare(project, from: shareView)
    }
    
    @objc private func didTapComments(gesture: UITapGestureRecognizer) {
        log.i("Did tap comment")
    }
    
    @objc private func didTapUpVote(gesture: UITapGestureRecognizer) {
        guard let project = project else {
            return log.i("tapped vote - did not configure table view cell")
        }
        
        // NOTE: There could be a weird issue where `project.voted` doesn't return until after the tap. There is no plan to "fix" this.
        // NOTE: This value will _not_ change from `project.voted`. The value selected here will "stick" permanently, regardless if there is a network issue. This simplifies this logic greatly as no PubSub is needed on this action.
        if didVote {
            didVote = false
            totalVotesImage.tintColor = UIColor.fromHex(0x657786)
            let numVotes: Int = max(project.numVotes + voteCount - 1, 0)
            totalVotesLabel.text = String(numVotes)
            delegate?.didTapVote(project, action: .remove)
            log.i("Removed vote")
            voteCount = 0
        }
        else {
            voteCount = 1
            didVote = true
            totalVotesImage.tintColor = UIColor.fromHex(0x130a33)
            totalVotesLabel.text = String(project.numVotes + voteCount)
            delegate?.didTapVote(project, action: .add)
            log.i("Added vote")
        }
    }
}

extension ProjectTableViewCell: ProjectImageCollectionViewDelegate {
    func didSelectProjectAsset(_ asset: ProjectAsset) {
        switch asset {
        case .image:
            // Images are not "Played", therefore, they behave as if the user tapped the cell.
            guard project != nil else {
                return log.c(notConfigured())
            }
            delegate?.didTapProjectCell(self)
        case .video:
            log.i("did tap video asset: \(asset)")
            break
        }
    }
    
    func didScrollToProjectAsset(_ asset: ProjectAsset, at index: Int) {
        log.i("Did scroll to asset: \(asset)")
    }
}

private func notConfigured() -> String {
    return "`ProjectTableViewCell` not configured"
}
