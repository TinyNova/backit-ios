/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

import BKFoundation

protocol ProjectFeedErrorViewDelegate: class {
    func didRequestToReloadData()
}

class ProjectFeedErrorView: UIView {
    
    @IBOutlet weak var errorMessageLabel: UILabel! {
        didSet {
            theme.apply(.informationalHeader, toLabel: errorMessageLabel)
        }
    }
    
    weak var delegate: ProjectFeedErrorViewDelegate?
    
    let i18n = Localization<Appl10n>()
    let theme: UIThemeApplier<AppTheme> = AppTheme.default

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        configure()
    }
    
    private func configure() {
        fromNib()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        addGestureRecognizer(gesture)
    }
    
    @objc private func didTapView(sender: UITapGestureRecognizer) {
        delegate?.didRequestToReloadData()
    }
}
