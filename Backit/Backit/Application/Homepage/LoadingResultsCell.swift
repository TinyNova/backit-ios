/**
 * TODO: Rename to `LoadingStatusCell`
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

enum LoadingResultsCellState {
    case loading
    case noResults
}

class LoadingResultsCell: UITableViewCell {
    
    @IBOutlet weak var stateLabel: UILabel!
    
    let i18n = Localization<Appl10n>()
    
    var state: LoadingResultsCellState = .noResults {
        didSet {
            switch state {
            case .loading:
                stateLabel.text = i18n.t(.loadingProjects)
            case .noResults:
                stateLabel.text = i18n.t(.youreUpToDate)
            }
        }
    }
    
    func configure(state: LoadingResultsCellState) {
        self.state = state
    }
}
