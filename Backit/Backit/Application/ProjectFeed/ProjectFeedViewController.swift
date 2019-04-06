/**
 * Project Feed (Homepage)
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

class ProjectFeedViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
//            tableView.delegate = self
            tableView.estimatedRowHeight = 300
            tableView.estimatedSectionHeaderHeight = 0
            tableView.estimatedSectionFooterHeight = 0
            tableView.separatorStyle = .none
            
            tableView.register(UINib(nibName: "ProjectTableViewCell", bundle: nil), forCellReuseIdentifier: "ProjectTableViewCell")
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

extension ProjectFeedViewController: HomepageClient {
    func didReceiveProjects(_ projects: [HomepageProject]) {
//        errorView.isHidden = true
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
//            errorView.isHidden = false
//            view.bringSubviewToFront(errorView)
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
//            let project = projects[indexPath.row]
//            cell.configure(project: project)
//            cell.delegate = self
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
    
    private func feedCell(_ tableView: UITableView) -> ProjectTableViewCell {
        guard let dequedCell = tableView.dequeueReusableCell(withIdentifier: "ProjectTableViewCell"), let cell = dequedCell as? ProjectTableViewCell else {
            fatalError("Failed to deque ProjectTableViewCell")
        }
        cell.selectionStyle = .none
        return cell
    }
}
