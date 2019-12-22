import Foundation
import UIKit

private enum SearchRowType {
    case category(Category)
    case subcategory(Category)
    case keyword(String)
    case gutter
}

class SearchViewController: UIViewController {
    
    private enum Identifier {
        static let GroupTypeCell = "GroupTypeCell"
        static let TinyProjectCell = "TinyProjectCell"
        static let GutterCell = "GutterCell"
    }
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    @IBOutlet private weak var searchFieldBackgroundView: UIView! {
        didSet {
            searchFieldBackgroundView.backgroundColor = UIColor.bk.purple
        }
    }
    @IBOutlet private(set) weak var cancelButton: UIButton! {
        didSet {
            cancelButton.setTitle("Cancel", for: .normal)
            cancelButton.setTitleColor(UIColor.bk.white, for: .normal)
            
            let tap = UILongPressGestureRecognizer(target:self, action: #selector(didTapCancel))
            tap.minimumPressDuration = 0
            cancelButton.gestureRecognizers = [tap]
            cancelButton.isUserInteractionEnabled = true
        }
    }
    @IBOutlet private(set) weak var searchIconView: CenteredImageView! {
        didSet {
            searchIconView.configure(image: UIImage(named: "search")?.sd_tintedImage(with: UIColor.bk.white), size: 30.0)
        }
    }
    @IBOutlet private weak var searchTextField: UITextField! {
        didSet {
            theme.apply(.search, toTextField: searchTextField)
            searchTextField.delegate = self
            searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }
    
    private var theme: UIThemeApplier<AppTheme> = AppTheme.default
    private var rows: [SearchRowType] = []
    private var projects: [Project] = []
    
    private var searchProvider: ProjectSearchProvider?
    private var navigationThemeApplier: NavigationThemeApplier?
    
    func inject(searchProvider: ProjectSearchProvider, navigationThemeApplier: NavigationThemeApplier) {
        self.searchProvider = searchProvider
        self.navigationThemeApplier = navigationThemeApplier
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = searchTextField.becomeFirstResponder()
        
        navigationThemeApplier?.applyTo(navigationController?.navigationBar)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc private func didTapCancel(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func updateResult(result: ProjectSearchResult) {
        var rows = [SearchRowType]()
        for row in result.categories {
            rows.append(.category(row))
        }
        for row in result.subcategories {
            rows.append(.subcategory(row))
        }
        for keyword in result.keywords {
            rows.append(.keyword(keyword))
        }
        rows.append(.gutter)
        self.rows = rows
        tableView.reloadData()

        result.projects.onSuccess { [weak self] (result) in
            guard let sself = self else {
                return
            }
            sself.projects = result?.projects ?? [Project]()
            sself.tableView.reloadSections([1], with: .automatic)
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        searchProvider?.resultsFor(token: textField.text, hasEarlyBirdRewards: true).onSuccess { [weak self] result in
            self?.updateResult(result: result)
        }
    }
}

extension SearchViewController: UITextFieldDelegate {
//    func didSubmit(field: TextEntryField) {
//        // TODO: Perform search if not searching.
//    }
//
//    func didChangeText(field: TextEntryField, text: String?) {
//    }
}

extension SearchViewController: UITableViewDelegate {
    // TODO: Tapping category, subcategory, keyword displays results
    // TODO: Tapping project opens the project details page
}

extension SearchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return rows.count
        }
        else {
            return projects.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.section == 0 else {
            return UITableView.automaticDimension
        }
        let row = rows[indexPath.row]
        switch row {
        case .gutter:
            return 30.0
        default:
            return 38.0
        }
    }
    
    private func groupCell(type: String, name: String) -> GroupTypeTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.GroupTypeCell) as? GroupTypeTableViewCell else {
            fatalError("Failed to load `GroupTypeCell`")
        }
        cell.configure(type: type, name: name)
        return cell
    }
    
    private func gutterCell() -> GutterTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.GutterCell) as? GutterTableViewCell else {
            fatalError("Failed to load `GutterCell`")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let row = rows[indexPath.row]
            switch row {
            case .category(let category):
                return groupCell(type: "Category", name: category.name)
            case .subcategory(let category):
                return groupCell(type: "Subcategory", name: category.name)
            case .keyword(let keyword):
                return groupCell(type: "Keyword", name: keyword)
            case .gutter:
                return gutterCell()
            }
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.TinyProjectCell) as? TinyProjectTableViewCell else {
                fatalError("Failed to load `TinyProjectCell`")
            }
            let project = projects[indexPath.row]
            cell.configure(project: project)
            return cell
        }
    }
}

class GroupTypeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            theme.apply(.regularBold, toLabel: nameLabel)
        }
    }
    @IBOutlet weak var valueLabel: UILabel! {
        didSet {
            theme.apply(.regular, toLabel: valueLabel)
        }
    }
    
    private var theme: UIThemeApplier<AppTheme> = AppTheme.default

    func configure(type: String, name: String) {
        nameLabel.text = type
        valueLabel.text = name
    }
}

class GutterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var gutterView: UIView! {
        didSet {
            theme.apply(.gutter, toView: gutterView)
        }
    }
    @IBOutlet weak var separatorView: UIView! {
        didSet {
            theme.apply(.lineSeparator, toView: separatorView)
        }
    }
    
    private var theme: UIThemeApplier<AppTheme> = AppTheme.default
}

class TinyProjectTableViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            theme.apply(.smallProjectName, toLabel: nameLabel)
        }
    }
    @IBOutlet weak var progressBarView: UIProgressView! {
        didSet {
            theme.apply(.fundedPercent, toProgressView: progressBarView)
        }
    }
    @IBOutlet weak var daysLeftLabel: UILabel! {
        didSet {
            theme.apply(.details, toLabel: daysLeftLabel)
        }
    }
    @IBOutlet weak var earlyBirdRewardsLabel: UILabel! {
        didSet {
            theme.apply(.details, toLabel: earlyBirdRewardsLabel)
        }
    }
    @IBOutlet weak var separatorView: UIView! {
        didSet {
            theme.apply(.lineSeparator, toView: separatorView)
        }
    }
    
    private var theme: UIThemeApplier<AppTheme> = AppTheme.default

    func configure(project: Project) {
        let imageWidth = thumbnailImageView.frame.size.width
//        let url = URL(string: "https://s3.amazonaws.com/backit.com/img/test/eric-250.jpg")!
        thumbnailImageView.sd_setImage(with: project.imageURLs.first) { [weak self] (image, error, cacheType, url) in
            let projectImage = image?.fittedImage(to: imageWidth)
            self?.thumbnailImageView.image = projectImage
        }
        nameLabel.text = project.name
        var fundedPercent = project.pledged > 0
            ? Float(project.pledged) / Float(project.goal)
            : 0
        fundedPercent = fundedPercent > 1 ? 1 : fundedPercent
        progressBarView.progress = fundedPercent
        if project.numDaysLeft == 1 {
            daysLeftLabel.text = "1 day left"
        }
        else {
            daysLeftLabel.text = "\(project.numDaysLeft) days left"
        }
        if project.numEarlyBirdRewards == 1 {
            earlyBirdRewardsLabel.text = "1 early bird"
        }
        else {
            earlyBirdRewardsLabel.text = "\(project.numEarlyBirdRewards) early birds"
        }
    }
}

class SearchOptionCell: UITableViewCell {
    
    func configure(title: String, on: Bool) {
        
    }
}
