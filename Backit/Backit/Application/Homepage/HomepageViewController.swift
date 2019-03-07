/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import AVKit
import MediaPlayer
import UIKit

protocol HomepageClient: class {
    func didReceiveProjects(_ projects: [HomepageProject])
    func didReachEndOfProjects()
    func didReceiveError(_ error: Error)
}

protocol HomepageProvider {
    var client: HomepageClient? { get set }
    
    func viewDidLoad()
    func didTapAsset(project: HomepageProject)
    func didTapBackit(project: HomepageProject)
    func didTapComment(project: HomepageProject)
    func didReachEndOfProjectList()
}

class HomepageViewController: UIViewController {

    
    @IBOutlet weak var errorView: HomepageErrorView! {
        didSet {
            errorView.isHidden = true
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.allowsSelection = false
            tableView.estimatedRowHeight = 300
            tableView.estimatedSectionHeaderHeight = 0
            tableView.estimatedSectionFooterHeight = 0
            tableView.separatorStyle = .none
            
            tableView.register(UINib(nibName: "HomepageProjectCell", bundle: nil), forCellReuseIdentifier: "HomepageProjectCell")
            tableView.register(UINib(nibName: "LoadingResultsCell", bundle: nil), forCellReuseIdentifier: "LoadingResultsCell")
        }
    }
    
    private let theme = UIThemeApplier<AppTheme>()
    private var provider: HomepageProvider!
    
    private var projects: [HomepageProject] = []
    private var loadingState: LoadingResultsCellState = .loading
    
    func inject(theme: AnyUITheme<AppTheme>, provider: HomepageProvider) {
        self.theme.concrete = theme
        self.provider = provider
        self.provider.client = self
    }
    
    private let i18n = Localization<Appl10n>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        provider.viewDidLoad()
    }
    
    var totalRows: Int {
        return projects.count + 1 /* Status Cell */
    }
}

extension HomepageViewController: HomepageClient {
    func didReceiveProjects(_ projects: [HomepageProject]) {
        self.projects.append(contentsOf: projects)
        tableView.reloadData()
    }
    
    func didReachEndOfProjects() {
        // TODO: Tapping cell could send a signal to reload the results from the beginning
        loadingState = .noResults
        tableView.reloadRows(at: [[0, totalRows-1]], with: .bottom)
    }
    
    func didReceiveError(_ error: Error) {
        errorView.isHidden = false
        view.bringSubviewToFront(errorView)
    }
}

extension HomepageViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if totalRows - indexPath.row == 1 {
            let cell = loadingResultsCell(tableView)
            cell.state = loadingState
            if loadingState == .loading {
                provider.didReachEndOfProjectList()
            }
            return cell
        }
        else {
            let cell = homepageProjectCell(tableView)
            let project = projects[indexPath.row]
            cell.configure(project: project)
            cell.delegate = self
            return cell
        }
    }
    
    private func loadingResultsCell(_ tableView: UITableView) -> LoadingResultsCell {
        guard let dequedCell = tableView.dequeueReusableCell(withIdentifier: "LoadingResultsCell"), let cell = dequedCell as? LoadingResultsCell else {
            fatalError("Failed to deque HomepageProjectCell")
        }
        return cell
    }
    
    private func homepageProjectCell(_ tableView: UITableView) -> HomepageProjectCell {
        guard let dequedCell = tableView.dequeueReusableCell(withIdentifier: "HomepageProjectCell"), let cell = dequedCell as? HomepageProjectCell else {
            fatalError("Failed to deque HomepageProjectCell")
        }
        return cell
    }
}

extension HomepageViewController: HomepageProjectCellDelegate {
    func didTapProject(_ project: HomepageProject) {
        print("Did tap project title")
    }
    
    func didTapComments(_ project: HomepageProject) {
        print("Did tap comments")
    }
    
    func didTapAsset(_ project: ProjectAsset) {
        guard case .video(_, let videoURL) = project else {
            return
        }
        
        let player = AVPlayer(url: videoURL)
        let vc = AVPlayerViewController()
        vc.player = player
        present(vc, animated: true) {
            player.play()
        }
    }
}
