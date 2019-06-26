/**
 * Project Feed (Homepage)
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import AVKit
import Foundation
import MediaPlayer
import UIKit

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
    
    private var provider: ProjectFeedProvider?
    private var signInProvider: SignInProvider?
    private var overlay: ProgressOverlayProvider?
    private var banner: BannerProvider?
    
    private var projects: [FeedProject] = []
    private var loadingState: LoadingResultsCellState = .ready
    
    func inject(theme: AnyUITheme<AppTheme>, provider: ProjectFeedProvider, userStreamer: UserStreamer, signInProvider: SignInProvider, overlay: ProgressOverlayProvider, banner: BannerProvider) {
        self.provider = provider
        self.provider?.client = self
        userStreamer.listen(self)
        self.signInProvider = signInProvider
        self.overlay = overlay
        self.banner = banner
    }
    
    private let i18n = Localization<Appl10n>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tab bar button
        tabBarItem = UITabBarItem.tabBarItem(using: "home")
        tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        
        // Right navigation buttons
        let searchButton = makeSearchButton()
        navigationItem.rightBarButtonItems = [searchButton]
        
        // Left navigation buttons
        let backitButton = makeBackitLogoButton()
        navigationItem.leftBarButtonItems = [backitButton]
        
//        provider?.loadProjects()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//    }
    
    // MARK: Actions
    
    @objc private func didTapSearch(_ sender: Any) {
        log.i("did tap search")
    }
    
    @objc private func didTapLogo(_ sender: Any) {
        log.i("did tap logo")
    }
    
    // MARK: Private functions
    
    private var totalRows: Int {
        return projects.count + 1 /* Status Cell */
    }
    
    private func reloadLastRowInTable() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: [[0, self.totalRows-1]], with: .bottom)
            self.tableView.endUpdates()
        }
    }
    
    private func makeSearchButton() -> UIBarButtonItem {
        let searchImage = UIImage(named: "search")?
            .fittedImage(to: 24.0)?
            .sd_tintedImage(with: UIColor.fromHex(0x5f637b))
        
        let searchButton = UIBarButtonItem(image: searchImage, style: .plain, target: self, action: #selector(didTapSearch))
        searchButton.imageInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        return searchButton
    }
    
    private func makeBackitLogoButton() -> UIBarButtonItem {
        let image = UIImage(named: "backit-logo")?
            .fittedImage(to: 40.0)?
            .sd_tintedImage(with: UIColor.white)
        return UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(didTapLogo))
    }
}

extension ProjectFeedViewController: ProjectFeedClient {
    func didReceiveProjects(_ projects: [FeedProject]) {
        if !errorView.isHidden {
            errorView.isHidden = true
            view.bringSubviewToFront(tableView)
        }
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
                provider?.didReachEndOfProjectList()
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
        log.i("Did tap project title")
    }
    
    func didTapComments(_ project: FeedProject) {
        log.i("Did tap comments")
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
        provider?.loadProjects()
    }
}

extension ProjectFeedViewController: UserStreamListener {
    func didChangeUser(_ user: User?) {
        // TODO: Query user's preferred projects.
    }
}
