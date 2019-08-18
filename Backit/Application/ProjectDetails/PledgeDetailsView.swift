import Foundation
import UIKit

class PledgeDetailsView: UIView {
    
    @IBOutlet private weak var pledgeAmountLabel: UILabel! {
        didSet {
            theme.apply(.regularBold, .currency, toLabel: pledgeAmountLabel)
        }
    }
    @IBOutlet private weak var nameLabel: UILabel! {
        didSet {
            theme.apply(.regular, toLabel: nameLabel)
        }
    }
    @IBOutlet private weak var includesLabel: UILabel! {
        didSet {
            includesLabel.text = "Includes"
            theme.apply(.small, .detail, toLabel: includesLabel)
        }
    }
    @IBOutlet private weak var rewardsLeftLabel: UILabel! {
        didSet {
            theme.apply(.regular, toLabel: rewardsLeftLabel)
        }
    }
    @IBOutlet private weak var tableView: UITableView!
    
    private let i18n = Localization<Appl10n>()
    private let theme: UIThemeApplier<AppTheme> = AppTheme.default

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        guard let view = fromNib() else {
            return
        }
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.black.cgColor
    }

    func configure(with reward: Reward) {
        pledgeAmountLabel.text = "$\(String(reward.cost))"
        nameLabel.text = reward.name
        // TODO: Wrong label name
        rewardsLeftLabel.text = "\(reward.numberOfBackers) backers"
    }
}
