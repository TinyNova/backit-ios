import Foundation
import UIKit

struct FeedProject {
    let context: Any
    let source: ProjectSource
    let assets: [ProjectAsset]
    let name: String
    let numberOfBackers: Int
    let comment: ProjectComment
    let isEarlyBird: Bool
    let fundedPercent: Float
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
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var totalVotesLabel: UILabel!
    @IBOutlet weak var totalCommentsLabel: UILabel!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var bottomSpacerView: UIView!
    
    private(set) var project: FeedProject? {
        didSet {
            
        }
    }
    
    func configure(with project: FeedProject) {
        
    }
}
