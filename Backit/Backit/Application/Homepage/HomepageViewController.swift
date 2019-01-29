/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import AVKit
import MediaPlayer
import UIKit

protocol HomepageClient: class {
    func didReceiveProjects(_ projects: [HomepageProject])
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

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.allowsSelection = false
            tableView.estimatedRowHeight = 300
            tableView.estimatedSectionHeaderHeight = 0
            tableView.estimatedSectionFooterHeight = 0
            
            tableView.register(UINib(nibName: "HomepageProjectCell", bundle: nil), forCellReuseIdentifier: "HomepageProjectCell")
        }
    }
    
    private let theme = UIThemeApplier<AppTheme>()
    private var provider: HomepageProvider!
    
    private var projects: [HomepageProject] = []
    
    func inject(theme: AnyUITheme<AppTheme>, provider: HomepageProvider) {
        self.theme.concrete = theme
        self.provider = provider
        self.provider.client = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        provider.viewDidLoad()
    }
}

extension HomepageViewController: HomepageClient {
    func didReceiveProjects(_ projects: [HomepageProject]) {
        self.projects.append(contentsOf: projects)
        tableView.reloadData()
    }
}

extension HomepageViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dequedCell = tableView.dequeueReusableCell(withIdentifier: "HomepageProjectCell"), let cell = dequedCell as? HomepageProjectCell else {
            fatalError("Failed to deque HomepageProjectCell")
        }
        
        if projects.count - indexPath.row == 1 {
            provider.didReachEndOfProjectList()
        }
        
        let project = projects[indexPath.row]
        cell.configure(project: project)
        cell.delegate = self
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
