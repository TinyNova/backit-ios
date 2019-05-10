import Foundation
import UIKit

class ProjectTableViewCell: UITableViewCell {
    
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var imagePageIndicator: UIStackView!
    @IBOutlet weak var imageCarousel: UIStackView!
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
}
