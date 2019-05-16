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
    
    @IBOutlet weak var fundedPercentProgressView: UIProgressView!
    
    @IBOutlet weak var percentFundedLabel: UILabel! {
        didSet {
            percentFundedLabel.textColor = UIColor.fromHex(0x6b6c7e)
        }
    }
    
    @IBOutlet weak var earlyBirdLabel: UILabel! {
        didSet {
            earlyBirdLabel.textColor = UIColor.fromHex(0x6b6c7e)
        }
    }
    
    @IBOutlet weak var daysLeftLabel: UILabel! {
        didSet {
            daysLeftLabel.textColor = UIColor.fromHex(0x6b6c7e)
        }
    }
    
    @IBOutlet weak var separatorView: UIView! {
        didSet {
            separatorView.backgroundColor = UIColor.fromHex(0xcdced9)
        }
    }
    
    @IBOutlet weak var totalVotesLabel: UILabel! {
        didSet {
            totalVotesLabel.textColor = UIColor.fromHex(0x6b6c7e)
        }
    }
    
    @IBOutlet weak var totalCommentsLabel: UILabel! {
        didSet {
            totalCommentsLabel.textColor = UIColor.fromHex(0x6b6c7e)
        }
    }
    
    @IBOutlet weak var shareLabel: UILabel! {
        didSet {
            shareLabel.textColor = UIColor.fromHex(0x6b6c7e)
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
