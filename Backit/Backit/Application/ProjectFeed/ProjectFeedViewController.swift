/**
 * Project Feed (Homepage)
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import AVKit
import Foundation
import Hero
import MediaPlayer
import SDWebImage
import UIKit

// This defines the image (cell) size for all views that display an image/video.
var ProjectImageSize: CGSize = .zero

private let MainScreenSizeWidth = UIScreen.main.bounds.size.width
private let iPhone5sImageSize = CGSize(width: MainScreenSizeWidth, height: 180.0)

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
            tableView.delegate = self
            tableView.estimatedRowHeight = 582
            tableView.estimatedSectionHeaderHeight = 0
            tableView.estimatedSectionFooterHeight = 0
            tableView.separatorStyle = .none
            
            tableView.register(UINib(nibName: "ProjectTableViewCell", bundle: nil), forCellReuseIdentifier: "ProjectTableViewCell")
            tableView.register(UINib(nibName: "LoadingResultsCell", bundle: nil), forCellReuseIdentifier: "LoadingResultsCell")
        }
    }
    
    private var provider: ProjectFeedProvider?
    private var pageProvider: PageProvider?
    private var projectProvider: ProjectProvider?
    private var signInProvider: SignInProvider?
    private var overlay: ProgressOverlayProvider?
    private var banner: BannerProvider?
    private var shareProvider: ShareProvider?
    
    private var projects: [FeedProject] = []
    private var loadingState: LoadingResultsCellState = .ready
    
    func inject(theme: AnyUITheme<AppTheme>, pageProvider: PageProvider, projectProvider: ProjectProvider, provider: ProjectFeedProvider, signInProvider: SignInProvider, overlay: ProgressOverlayProvider, banner: BannerProvider, shareProvider: ShareProvider) {
        self.provider = provider
        self.provider?.client = self
        self.pageProvider = pageProvider
        self.projectProvider = projectProvider
        self.signInProvider = signInProvider
        self.overlay = overlay
        self.banner = banner
        self.shareProvider = shareProvider
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
        
        provider?.loadProjects()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        overlay?.show()
//        banner?.present(message: BannerMessage(type: .error, title: "A title", message: "A very long message which should make the box grow. This should go way beyond the height of the box! My goodness this is a long message! The last one wasn't long enough!? Well this should do it now!", button1: nil, button2: nil), in: self)
//        banner?.present(message: BannerMessage(type: .error, title: "An Error Occurred", message: "An unexplained error occurred.", button1: nil, button2: nil), in: self)
    }
    
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
    
    private func displayProjectDetails(from cell: ProjectTableViewCell?) {
        guard let project = cell?.project else {
            // NOTE: It could also be that the "Loading cell" was tapped
            return log.w("`FeedProject` is not known")
        }
        guard let viewController = pageProvider?.projectDetails() else {
            return log.c("Failed to display Project Details")
        }
        viewController.configure(with: project)
        viewController.hero.isEnabled = true
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.present(viewController, animated: true, completion: nil)
        }
    }
}

extension ProjectFeedViewController: ProjectFeedClient {
    func didReceiveProjects(_ projects: [FeedProject], reset: Bool) {
        if reset {
            clearProjects()
        }
        
        if ProjectImageSize.height < 1 {
            // TODO: Make this logic a dependency.
            let asset = projects.first?.assets.first(where: { (asset) -> Bool in
                switch asset {
                case .image:
                    return true
                case .video:
                    return false
                }
            })
            
            guard case .image(let imageUrl)? = asset else {
                log.e("The first project has no image!")
                ProjectImageSize = iPhone5sImageSize
                addProjects(projects)
                return
            }
            
            let manager = SDWebImageManager.shared
            manager.loadImage(with: imageUrl, options: [], progress: nil) { [weak self] (image, data, error, cacheType, finished, imageURL) in
                guard let image = image else {
                    // FIXME: Retry this operation
                    log.e("Failed to download the first image!")
                    ProjectImageSize = iPhone5sImageSize
                    self?.addProjects(projects)
                    return
                }

                ProjectImageSize = image.proportionalScaledSize(using: MainScreenSizeWidth)
                self?.addProjects(projects)
            }
        }
        else {
            addProjects(projects)
        }
    }
    
    private func addProjects(_ projects: [FeedProject]) {
        if !errorView.isHidden {
            errorView.isHidden = true
            view.bringSubviewToFront(tableView)
        }
        self.projects.append(contentsOf: projects)
        tableView.reloadData()
    }
    
    private func clearProjects() {
        self.projects = []
        // We don't reload the table data as we are assuming that we will be adding projects directly after this.
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

extension ProjectFeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? ProjectTableViewCell
        displayProjectDetails(from: cell)
    }
}

extension ProjectFeedViewController: ProjectTableViewCellDelegate {
    func didTapProjectCell(_ cell: ProjectTableViewCell) {
        displayProjectDetails(from: cell)
    }
    
    func didTapComments(_ project: FeedProject) {
        log.i("Did tap comments")
    }
    
    func didTapShare(_ project: FeedProject, from view: UIView) {
        guard let project = project.context as? Project,
              let url = project.internalUrl else {
            // TODO: Display an error
            return log.e("There is no Backit URL to share")
        }
        shareProvider?.shareUrl(url, from: view)
            .onSuccess { _ in
                // TODO: Show some type of feedback
            }
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
    
    func didTapVote(_ project: FeedProject, action: VoteAction) {
        provider?.didVoteFor(project: project, action: action)
    }
}

extension ProjectFeedViewController: ProjectFeedErrorViewDelegate {
    func didRequestToReloadData() {
        provider?.loadProjects()
    }
}
