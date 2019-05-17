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
            fundedPercentProgressView.tintColor = UIColor.fromHex(0x00ce76)
            fundedPercentProgressView.trackTintColor = UIColor.fromHex(0xccd6dd)
            let transform = CATransform3DScale(fundedPercentProgressView.layer.transform, 1.0, 2.0, 1.0);
            fundedPercentProgressView.layer.transform = transform
            fundedPercentProgressView.layer.cornerRadius = 2.0
            fundedPercentProgressView.layer.masksToBounds = true
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
            separatorView.backgroundColor = UIColor.fromHex(0xcdced9)
        }
    }
    
    @IBOutlet weak var totalVotesLabel: UILabel! {
        didSet {
            theme.apply(.smallInfoLabel, toLabel: totalVotesLabel)
        }
    }
    
    @IBOutlet weak var totalCommentsLabel: UILabel! {
        didSet {
            theme.apply(.smallInfoLabel, toLabel: totalCommentsLabel)
        }
    }
    
    @IBOutlet weak var shareLabel: UILabel! {
        didSet {
            theme.apply(.smallInfoLabel, toLabel: shareLabel)
        }
    }
    
    @IBOutlet weak var bottomSpacerView: UIView! {
        didSet {
            bottomSpacerView.backgroundColor = UIColor.fromHex(0xf5f8fa)
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
            earlyBirdLabel.text = "todo"
            daysLeftLabel.text = "todo"
            
            totalVotesLabel.text = "todo"
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
