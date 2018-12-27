/**
 *
 * Copyright © 2018 Backit. All rights reserved.
 */
 
import UIKit

enum ProjectComment {
    case comments(Int)
    case comment
}

enum ProjectAsset {
    case image(URL)
    case video(URL)
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
    let fundedPercent: Int
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
        }
    }
    
    private var projects: [HomepageProject] = []
    
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell") else {
            fatalError("Failed to deque ProjectCell")
        }
        let project = projects[indexPath.row]
        cell.textLabel?.text = project.name
        if let asset = project.assets.first, case .image(let imageURL) = asset {
            // TODO: Load image
        }
        return cell
    }
}
