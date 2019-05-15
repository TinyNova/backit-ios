/**
 * Project Feed (Homepage)
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import AVKit
import Foundation
import MediaPlayer
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
    
    static func make(from project: Project) -> FeedProject {
        var assets: [ProjectAsset] = []
        assets.append(.image(project.imageURLs[0]))
        if let previewURL = project.videoPreviewURL, let videoURL = project.videoURL {
            assets.append(.video(previewURL: previewURL, videoURL: videoURL))
        }
        
        let fundedPercent = project.pledged > 0
            ? Float(project.pledged) / Float(project.goal)
            : 0
        
        return FeedProject(
            context: 1,
            source: project.source,
            assets: assets,
            name: project.name,
            numberOfBackers: project.numBackers,
            comment: .comment,
            isEarlyBird: project.hasEarlyBirdRewards,
            fundedPercent: fundedPercent
        )
    }
}

protocol ProjectFeedClient: class {
    func didReceiveProjects(_ projects: [FeedProject])
    func didReachEndOfProjects()
    func didReceiveError(_ error: Error)
}

protocol ProjectFeedProvider {
    var client: ProjectFeedClient? { get set }
    
    func loadProjects()
    func didTapAsset(project: FeedProject)
    func didTapBackit(project: FeedProject)
    func didTapComment(project: FeedProject)
    func didReachEndOfProjectList()
}

class ProjectFeedViewController: UIViewController {
    
    @IBOutlet weak var errorView: ProjectFeedErrorView! {
        didSet {
            errorView.isHidden = true
            errorView.delegate = self
        }
    }

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
//            tableView.delegate = self
            tableView.estimatedRowHeight = 582
            tableView.estimatedSectionHeaderHeight = 0
            tableView.estimatedSectionFooterHeight = 0
            tableView.separatorStyle = .none
            
            tableView.register(UINib(nibName: "ProjectTableViewCell", bundle: nil), forCellReuseIdentifier: "ProjectTableViewCell")
            tableView.register(UINib(nibName: "LoadingResultsCell", bundle: nil), forCellReuseIdentifier: "LoadingResultsCell")
        }
    }
    
    private var provider: ProjectFeedProvider!
    
    private var projects: [FeedProject] = []
    private var loadingState: LoadingResultsCellState = .ready
    
    func inject(theme: AnyUITheme<AppTheme>, provider: ProjectFeedProvider) {
        self.provider = provider
        self.provider.client = self
    }
    
    private let i18n = Localization<Appl10n>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarItem = UITabBarItem.tabBarItem(using: "home")
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

extension ProjectFeedViewController: ProjectFeedClient {
    func didReceiveProjects(_ projects: [FeedProject]) {
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

extension ProjectFeedViewController: UITableViewDataSource {
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
            let cell = feedCell(tableView)
            let project = projects[indexPath.row]
            cell.configure(with: project)
            cell.delegate = self
            return cell
        }
    }
    
    private func loadingResultsCell(_ tableView: UITableView) -> LoadingResultsCell {
        guard let dequedCell = tableView.dequeueReusableCell(withIdentifier: "LoadingResultsCell"), let cell = dequedCell as? LoadingResultsCell else {
            fatalError("Failed to deque LoadingResultsCell")
        }
        cell.selectionStyle = .none
        return cell
    }
    
    private func feedCell(_ tableView: UITableView) -> ProjectTableViewCell {
        guard let dequedCell = tableView.dequeueReusableCell(withIdentifier: "ProjectTableViewCell"), let cell = dequedCell as? ProjectTableViewCell else {
            fatalError("Failed to deque ProjectTableViewCell")
        }
        cell.selectionStyle = .none
        return cell
    }
}

extension ProjectFeedViewController: ProjectTableViewCellDelegate {
    func didTapProject(_ project: FeedProject) {
        print("Did tap project title")
    }
    
    func didTapComments(_ project: FeedProject) {
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

extension ProjectFeedViewController: ProjectFeedErrorViewDelegate {
    func didRequestToReloadData() {
        provider.loadProjects()
    }
}
