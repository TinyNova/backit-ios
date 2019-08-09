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
    
    @IBOutlet private weak var closeImageView: UIImageView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCloseButton))
            closeImageView.tintColor = UIColor.fromHex(0x000000)
            closeImageView.addGestureRecognizer(tap)
            closeImageView.isUserInteractionEnabled = true
            closeImageView.alpha = 0.7
            closeImageView.hero.modifiers = [.fade]
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
    
    @IBOutlet weak var authorAvatarImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel! {
        didSet {
            theme.apply(.author, toLabel: authorLabel)
            authorLabel.text = ""
        }
    }
    @IBOutlet weak var progressView: UIProgressView! {
        didSet {
            theme.apply(.fundedPercent, toProgressView: progressView)
        }
    }
    
    @IBOutlet weak var blurbLabel: UILabel! {
        didSet {
            // TODO: Add more padding on top and bottom. Make this 40pt. Add chevron. If text is > N chars, add 'more...' button. The more button will simply expand the text.
            theme.apply(.blurb, toLabel: blurbLabel)
            blurbLabel.text = ""
        }
    }
    @IBOutlet weak var projectDescriptionButton: UIButton! {
        didSet {
            theme.apply(.more, toButton: projectDescriptionButton)
            projectDescriptionButton.setTitle(i18n.t(.readCampaignDescription), for: .normal)
        }
    }
    
    @IBOutlet weak var locationImageView: CenteredImageView! {
        didSet {
            locationImageView.configure(image: UIImage(named: "location")?.sd_tintedImage(with: UIColor.fromHex(0x6b6c7e)), size: 15)
        }
    }
    @IBOutlet weak var locationLabel: UILabel! {
        didSet {
            theme.apply(.details, toLabel: locationLabel)
            locationLabel.text = ""
        }
    }
    
    @IBOutlet weak var categoryImageView: CenteredImageView! {
        didSet {
            categoryImageView.configure(image: UIImage(named: "category")?.sd_tintedImage(with: UIColor.fromHex(0x6b6c7e)), size: 15)
        }
    }
    @IBOutlet weak var categoryLabel: UILabel! {
        didSet {
            theme.apply(.details, toLabel: categoryLabel)
            categoryLabel.text = ""
        }
    }
    
    private let i18n = Localization<Appl10n>()
    private let theme: UIThemeApplier<AppTheme> = AppTheme.default

    private var project: FeedProject?
    private var projectFuture: Future<DetailedProject, ProjectProviderError>?
    
    func configure(with project: FeedProject, projectFuture: Future<DetailedProject, ProjectProviderError>) {
        self.project = project
        self.projectFuture = projectFuture
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
        log.i("Did tap project description button")
    }
    
    @objc func didTapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapPlayVideoButton(_ sender: Any) {
        log.i("Did tap play video button")
    }
    
    private func updateProject(with project: DetailedProject) {
        var fundedPercent = project.pledged > 0
            ? Float(project.pledged) / Float(project.goal)
            : 0
        // clamp to 100%
        fundedPercent = fundedPercent > 1 ? 1 : fundedPercent
        categoryLabel.text = project.category
        if let avatarUrl = project.author.avatarUrl {
            authorAvatarImageView.sd_setImage(with: avatarUrl, completed: nil)
        }
        else {
            authorAvatarImageView.image = UIImage(named: "avatar")
        }
        authorLabel.text = i18n.t(.byAuthor(project.author.name))
        progressView.progress = fundedPercent
        locationLabel.text = project.country
        theme.apply(.blurbText(project.blurb), toLabel: blurbLabel)
        if project.videoUrl != nil {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.playVideoButton.isHidden = false
            }
        }
        else {
            playVideoButton.isHidden = true
        }
        // TODO: Change the color of the progress bar to the respective source's brand color.
    }
}
