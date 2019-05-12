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
    
    @IBOutlet weak var projectNameLabel: UILabel!
    
    @IBOutlet weak var fundedPercentProgressView: UIProgressView!
    
    @IBOutlet weak var percentFundedLabel: UILabel!
    
    @IBOutlet weak var earlyBirdLabel: UILabel!
    
    @IBOutlet weak var daysLeftLabel: UILabel!
    
    @IBOutlet weak var separatorView: UIView! {
        didSet {
            // TODO: BG color
        }
    }
    
    @IBOutlet weak var totalVotesLabel: UILabel!
    
    @IBOutlet weak var totalCommentsLabel: UILabel!
    
    @IBOutlet weak var shareView: UIView!
    
    @IBOutlet weak var bottomSpacerView: UIView! {
        didSet {
            // TODO: BG color
        }
    }
    
    weak var delegate: ProjectTableViewCellDelegate?
    
    var i18n = Localization<Appl10n>()

    private(set) var project: FeedProject? {
        didSet {
            guard let project = project else {
                return
            }
            
            projectNameLabel.text = project.name
            fundedPercentProgressView.progress = project.fundedPercent
            let fundedPercent = Int(project.fundedPercent * 100)
            percentFundedLabel.text = i18n.t(.funded(amount: fundedPercent))

        }
    }
    
    func configure(with project: FeedProject) {
        self.project = project
    }
}
