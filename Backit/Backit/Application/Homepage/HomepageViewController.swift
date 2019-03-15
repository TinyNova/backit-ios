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
    
    func loadProjects()
    func didTapAsset(project: HomepageProject)
    func didTapBackit(project: HomepageProject)
    func didTapComment(project: HomepageProject)
    func didReachEndOfProjectList()
}

class HomepageViewController: UIViewController {

    
    @IBOutlet weak var errorView: HomepageErrorView! {
        didSet {
            errorView.isHidden = true
            errorView.delegate = self
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
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
    private var loadingState: LoadingResultsCellState = .ready
    
    func inject(theme: AnyUITheme<AppTheme>, provider: HomepageProvider) {
        self.theme.concrete = theme
        self.provider = provider
        self.provider.client = self
    }
    
    private let i18n = Localization<Appl10n>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        provider.loadProjects()
    }
    
    var totalRows: Int {
        return projects.count + 1 /* Status Cell */
    }
    
    func reloadLastRowInTable() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: [[0, self.totalRows-1]], with: .bottom)
            self.tableView.endUpdates()
        }
    }
}

extension HomepageViewController: HomepageClient {
    func didReceiveProjects(_ projects: [HomepageProject]) {
        errorView.isHidden = true
        view.bringSubviewToFront(tableView)
        self.projects.append(contentsOf: projects)
        tableView.reloadData()
    }
    
    func didReachEndOfProjects() {
        // TODO: Tapping cell could send a signal to reload the results from the beginning
        loadingState = .noResults
        reloadLastRowInTable()
    }
    
    func didReceiveError(_ error: Error) {
        if totalRows < 2 {
            errorView.isHidden = false
            view.bringSubviewToFront(errorView)
        }
        else {
            loadingState = .error
            reloadLastRowInTable()
        }
    }
}

extension HomepageViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalRows
    }
    
    private var canLoadNextPageOfResults: Bool {
        return totalRows > 1 /* Must have had loaded at least one project in the table view */
            && loadingState == .ready /* Must be in a nominal state */
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if totalRows - indexPath.row == 1 {
            let cell = loadingResultsCell(tableView)
            cell.state = loadingState
            if canLoadNextPageOfResults {
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
        cell.selectionStyle = .none
        return cell
    }
    
    private func homepageProjectCell(_ tableView: UITableView) -> HomepageProjectCell {
        guard let dequedCell = tableView.dequeueReusableCell(withIdentifier: "HomepageProjectCell"), let cell = dequedCell as? HomepageProjectCell else {
            fatalError("Failed to deque HomepageProjectCell")
        }
        cell.selectionStyle = .none
        return cell
    }
}

extension HomepageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if case .error = loadingState, indexPath.row == totalRows - 1 {
            provider.loadProjects()
        }
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

extension HomepageViewController: HomepageErrorViewDelegate {
    func didRequestToReloadData() {
        provider.loadProjects()
    }
}
