import Foundation
import UIKit

protocol ProjectTableViewCellDelegate: class {
    func didTapProject(_ project: FeedProject)
    func didTapAsset(_ asset: ProjectAsset)
    func didTapComments(_ project: FeedProject)
}

class ProjectTableViewCell: UITableViewCell {
    
    @IBOutlet weak var favoriteImageView: UIImageView!
    
    @IBOutlet weak var imagePagerView: ImagePagerView!
    
    @IBOutlet weak var projectImageCollectionView: ProjectImageCollectionView!
    
    @IBOutlet weak var projectNameLabel: UILabel! {
        didSet {
            theme.apply(.feedProjectName, toLabel: projectNameLabel)
        }
    }
    
    @IBOutlet weak var fundedPercentProgressView: UIProgressView! {
        didSet {
            theme.apply(.fundedPercent, toProgressView: fundedPercentProgressView)
        }
    }
    
    @IBOutlet weak var percentFundedLabel: UILabel! {
        didSet {
            theme.apply(.smallInfoLabel, toLabel: percentFundedLabel)
        }
    }
    
    @IBOutlet weak var earlyBirdLabel: UILabel! {
        didSet {
            theme.apply(.smallInfoLabel, toLabel: earlyBirdLabel)
        }
    }
    
    @IBOutlet weak var daysLeftLabel: UILabel! {
        didSet {
            theme.apply(.smallInfoLabel, toLabel: daysLeftLabel)
        }
    }
    
    @IBOutlet weak var separatorView: UIView! {
        didSet {
            theme.apply(.lineSeparator, toView: separatorView)
        }
    }
    
    @IBOutlet weak var totalVotesImage: UIImageView! {
        didSet {
            totalVotesImage.tintColor = UIColor.fromHex(0x657786)
        }
    }
    @IBOutlet weak var totalVotesLabel: UILabel! {
        didSet {
            theme.apply(.smallInfoLabel, toLabel: totalVotesLabel)
        }
    }
    
    @IBOutlet weak var totalCommentsImage: UIImageView! {
        didSet {
            totalCommentsImage.tintColor = UIColor.fromHex(0x657786)
        }
    }
    @IBOutlet weak var totalCommentsLabel: UILabel! {
        didSet {
            theme.apply(.smallInfoLabel, toLabel: totalCommentsLabel)
        }
    }
    
    @IBOutlet weak var shareImage: UIImageView! {
        didSet {
            shareImage.tintColor = UIColor.fromHex(0x657786)
        }
    }
    @IBOutlet weak var shareLabel: UILabel! {
        didSet {
            theme.apply(.smallInfoLabel, toLabel: shareLabel)
        }
    }
    
    @IBOutlet weak var bottomSpacerView: UIView! {
        didSet {
            theme.apply(.gutter, toView: bottomSpacerView)
        }
    }
    
    weak var delegate: ProjectTableViewCellDelegate?
    
    let theme: UIThemeApplier<AppTheme> = AppTheme.default
    let i18n = Localization<Appl10n>()
    
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
}

//extension UIProgressView {
//    open override func sizeThatFits(_ size: CGSize) -> CGSize {
//        return CGSize(width: size.width, height: 9.0)
//    }
//}
