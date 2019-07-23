/**
 * TODO: Rename to `LoadingStatusCell`
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

import BKFoundation

enum LoadingResultsCellState {
    case ready
    case noResults
    case error
}

class LoadingResultsCell: UITableViewCell {
    
    @IBOutlet weak var stateLabel: UILabel!
    
    let i18n = Localization<Appl10n>()
    
    var state: LoadingResultsCellState = .noResults {
        didSet {
            switch state {
            case .ready:
                stateLabel.text = i18n.t(.loadingProjects)
            case .noResults:
                stateLabel.text = i18n.t(.youreUpToDate)
            case .error:
                stateLabel.text = i18n.t(.errorLoadingProjects)
            }
        }
    }
    
    func configure(state: LoadingResultsCellState) {
        self.state = state
    }
}
