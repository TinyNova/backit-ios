/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import BrightFutures
import Hero
import SDWebImage
import UIKit

class ProjectDetailsViewController: UIViewController {
        
    @IBOutlet weak var navigationBarView: UIView! {
        didSet {
            navigationBarView.backgroundColor = UIColor.bk.purple
        }
    }
    @IBOutlet weak var searchImageView: CenteredImageView! {
        didSet {
            searchImageView.configure(image: UIImage(named: "search")?.sd_tintedImage(with: UIColor.bk.white), size: 30.0)
            searchImageView.hero.id = "App.Search"
        }
    }
    @IBOutlet private weak var closeImageView: CenteredImageView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCloseButton))
            closeImageView.configure(image: UIImage(named: "close")?.sd_tintedImage(with: UIColor.bk.white), size: 30.0)
            closeImageView.addGestureRecognizer(tap)
            closeImageView.isUserInteractionEnabled = true
            closeImageView.hero.id = "App.Close"
        }
    }
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet weak var playVideoButton: UIImageView! {
        didSet {
            playVideoButton.isHidden = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(didTapPlayVideoButton))
            playVideoButton.addGestureRecognizer(tap)
            playVideoButton.isUserInteractionEnabled = true
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            theme.apply(.smallProjectName, toLabel: titleLabel)
            titleLabel.text = ""
        }
    }
    
    @IBOutlet private weak var authorAvatarImageView: UIImageView! {
        didSet {
            authorAvatarImageView.alpha = 0.0
        }
    }
    @IBOutlet private weak var authorLabel: UILabel! {
        didSet {
            theme.apply(.author, toLabel: authorLabel)
            authorLabel.text = ""
        }
    }
    @IBOutlet private weak var progressView: UIProgressView! {
        didSet {
            theme.apply(.fundedPercent, toProgressView: progressView)
            progressView.progress = 0.0
        }
    }
    
    @IBOutlet private weak var blurbLabel: UILabel! {
        didSet {
            // TODO: Add more padding on top and bottom. Make this 40pt. Add chevron. If text is > N chars, add 'more...' button. The more button will simply expand the text.
            theme.apply(.blurb, toLabel: blurbLabel)
            blurbLabel.text = ""
        }
    }
    @IBOutlet private weak var projectDescriptionButton: UIButton! {
        didSet {
            theme.apply(.more, toButton: projectDescriptionButton)
            projectDescriptionButton.setTitle(i18n.t(.readCampaignDescription), for: .normal)
        }
    }
    
    @IBOutlet private weak var locationImageView: CenteredImageView! {
        didSet {
            locationImageView.configure(image: UIImage(named: "location")?.sd_tintedImage(with: UIColor.fromHex(0x6b6c7e)), size: 15)
        }
    }
    @IBOutlet private weak var locationLabel: UILabel! {
        didSet {
            theme.apply(.details, toLabel: locationLabel)
            locationLabel.text = ""
        }
    }
    
    @IBOutlet private weak var categoryImageView: CenteredImageView! {
        didSet {
            categoryImageView.configure(image: UIImage(named: "category")?.sd_tintedImage(with: UIColor.fromHex(0x6b6c7e)), size: 15)
        }
    }
    @IBOutlet private weak var categoryLabel: UILabel! {
        didSet {
            theme.apply(.details, toLabel: categoryLabel)
            categoryLabel.text = ""
        }
    }
    
    @IBOutlet private weak var backerInfoLabel: UILabel! {
        didSet {
            theme.apply(.details, toLabel: backerInfoLabel)
            backerInfoLabel.text = ""
        }
    }
    @IBOutlet private weak var percentageInfoLabel: UILabel! {
        didSet {
            theme.apply(.details, toLabel: percentageInfoLabel)
            percentageInfoLabel.text = ""
        }
    }
    @IBOutlet private weak var daysLeftLabel: UILabel! {
        didSet {
            theme.apply(.details, toLabel: daysLeftLabel)
            daysLeftLabel.text = ""
        }
    }
    
    @IBOutlet private weak var rewardsStackView: UIStackView!
    
    private let i18n = Localization<Appl10n>()
    private let theme: UIThemeApplier<AppTheme> = AppTheme.default

    private var detailedProject: DetailedProject?
    private var project: FeedProject?
    private var projectFuture: Future<DetailedProject, ProjectProviderError>?
    private var pageProvider: PageProvider?
    
    func configure(with project: FeedProject, projectFuture: Future<DetailedProject, ProjectProviderError>) {
        self.project = project
        self.projectFuture = projectFuture
    }
    
    func inject(pageProvider: PageProvider) {
        self.pageProvider = pageProvider
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let context = project?.context as? Project else {
            return log.e("Call ProjectDetailsViewController.configure(with:)")
        }

        titleLabel.hero.id = ProjectFeedModule.HeroId.projectName(project?.id)
        imageView.hero.id = ProjectFeedModule.HeroId.projectImage(project?.id)
        categoryLabel.text = "STUFF"
        titleLabel.text = project?.name
        
        let manager = SDWebImageManager.shared
        manager.loadImage(with: context.imageURLs.first, options: [], progress: nil) { [weak self] (image, data, error, cachType, finished, url) in
            guard let size = image?.proportionalScaledSize(using: UIScreen.main.bounds.size.width) else {
                return log.w("Failed to get proportional image size")
            }
//            self?.imageView.image = image?.resizedImage(using: size)
            self?.imageView.image = image?.fittedImage(to: size.width)
        }
        
        projectFuture?.onSuccess(callback: updateProject(with:))

        // Back It
        // Pledged of Goal
        // # Backers
        // Project funding information
        // Last updated
        
        // - Toggle
        // The entire project's information (as a web view?)
        // Rewards
        // Community (Newest | Oldest | Popular)
    }
    
    @IBAction func didTapProjectDescriptionButton(_ sender: Any) {
        guard let nav = pageProvider?.projectDescription() else {
            return
        }
        guard let detailedProject = detailedProject else {
            return
        }
        guard let vc = nav.viewControllers.first as? ProjectDescriptionViewController else {
            return
        }
        vc.configureWith(htmlString: detailedProject.text)
        present(nav, animated: true, completion: nil)
    }
    
    @objc func didTapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapPlayVideoButton(_ sender: Any) {
        log.i("Did tap play video button")
    }
    
    private func updateProject(with project: DetailedProject) {
        detailedProject = project
        
        var fundedPercent = project.pledged > 0
            ? Float(project.pledged) / Float(project.goal)
            : 0
        // clamp to 100%
        fundedPercent = fundedPercent > 1 ? 1 : fundedPercent
        categoryLabel.text = project.category
        if let avatarUrl = project.author.avatarUrl {
            authorAvatarImageView.sd_setImage(with: avatarUrl) { [weak self] (image, error, cacheType, url) in
                self?.authorAvatarImageView.image = image?.fittedImage(to: 20.0)
                UIView.animate(withDuration: 0.3) {
                    self?.authorAvatarImageView.alpha = 1.0
                }
            }
        }
        else {
            authorAvatarImageView.image = UIImage(named: "avatar")
        }
        authorLabel.text = i18n.t(.byAuthor(project.author.name))
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.progressView.progress = fundedPercent
        }
        locationLabel.text = project.country
        theme.apply(.blurbText(project.blurb), toLabel: blurbLabel)
//        let identifiers = Locale.availableIdentifiers
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        
        let pledged = formatter.string(from: NSNumber(value: project.pledged))?.replacingOccurrences(of: ".00", with: "") ?? String(project.pledged)
        let goal = formatter.string(from: NSNumber(value: project.goal))?.replacingOccurrences(of: ".00", with: "") ?? String(project.goal)
        
        formatter.numberStyle = .decimal
        let numBackers = formatter.string(from: NSNumber(value: project.numBackers)) ?? String(project.numBackers)
        let attributedString = NSMutableAttributedString(string: "\(pledged) raised by \(numBackers) backers")
        attributedString.addAttribute(.font, value: FontCache.default.regular18, range: NSMakeRange(0, pledged.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor.fromHex(0x000000), range: NSMakeRange(0, pledged.count))
        backerInfoLabel.attributedText = attributedString
        
        percentageInfoLabel.text = "\(Int(fundedPercent * 100))% of \(goal) goal"
        
        daysLeftLabel.text = "\(project.numDaysLeft ?? 0) days left"
        if project.videoUrl != nil {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.playVideoButton.isHidden = false
            }
        }
        else {
            playVideoButton.isHidden = true
        }
        // TODO: Change the color of the progress bar to the respective source's brand color.
        
        for reward in project.rewards {
            let view = PledgeDetailsView()
            view.configure(with: reward)
            rewardsStackView.addArrangedSubview(view)
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}
