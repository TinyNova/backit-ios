/**
 *
 * Copyright © 2018 Backit. All rights reserved.
 */

import AVKit
import MediaPlayer
import UIKit

enum ProjectComment {
    case comments(Int)
    case comment
}

enum ProjectAsset {
    case image(URL)
    case video(previewURL: URL, videoURL: URL)
}

enum ProjectSource {
    case kickstarter
    case indiegogo
}

struct HomepageProject {
    let context: Any
    let source: ProjectSource
    let assets: [ProjectAsset]
    let name: String
    let numberOfBackers: Int
    let comment: ProjectComment
    let isEarlyBird: Bool
    let fundedPercent: Float
}

protocol HomepageDataSource {
    func didReceiveProjects(_ projects: [HomepageProject])
}

protocol HomepageDelegate {
    func didTapAsset(project: HomepageProject)
    func didTapBackit(project: HomepageProject)
    func didTapComment(project: HomepageProject)
}

class HomepageViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            
            tableView.register(UINib(nibName: "HomepageProjectCell", bundle: nil), forCellReuseIdentifier: "HomepageProjectCell")
        }
    }
    
    private let theme = UIThemeApplier<AppTheme>()
    
    // p = portrait
    // t = thumb
    // c = card
    private var projects: [HomepageProject] = [
        HomepageProject(
            context: 1,
            source: .kickstarter,
            assets: [
                .image(URL(string: "https://cdn.collect.backit.com/pictures/2/f/c/a/e/2fcae53923676aea72f9eeb7fae822e0t.jpg")!),
                .video(previewURL: URL(string: "https://s3.amazonaws.com/backit.com/tempt/youre-awesome.mp4")!, videoURL: URL(string: "https://s3.amazonaws.com/backit.com/tempt/youre-awesome.mp4")!),
                .image(URL(string: "https://cdn.collect.backit.com/pictures/2/f/c/a/e/2fcae53923676aea72f9eeb7fae822e0t.jpg")!)
            ],
            name: "KEYTO: The Key to Burning Fat Faster",
            numberOfBackers: 1234,
            comment: .comments(500),
            isEarlyBird: true,
            fundedPercent: 0.9
        )
    ]
    
    func inject(theme: AnyUITheme<AppTheme>) {
        self.theme.concrete = theme
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension HomepageViewController: HomepageDataSource {
    func didReceiveProjects(_ projects: [HomepageProject]) {
        self.projects = projects
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
        let project = projects[indexPath.row]
        cell.configure(project: project)
        cell.delegate = self
        return cell
    }
}

extension HomepageViewController: HomepageProjectCellDelegate {
    func didTapProject(_ project: ProjectAsset) {
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
