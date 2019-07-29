/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import BrightFutures
import Hero
import SDWebImage
import UIKit

import BKFoundation

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
            theme.apply(.feedProjectName, toLabel: titleLabel)
        }
    }
    @IBOutlet weak var authorLabel: UILabel! {
        didSet {
            theme.apply(.info, toLabel: authorLabel)
        }
    }
    @IBOutlet weak var progressView: UIProgressView! {
        didSet {
            theme.apply(.fundedPercent, toProgressView: progressView)
        }
    }
    @IBOutlet weak var blurbLabel: UILabel! {
        didSet {
            theme.apply(.info, toLabel: blurbLabel)
        }
    }
    @IBOutlet weak var locationLabel: UILabel! {
        didSet {
            theme.apply(.info, toLabel: locationLabel)
        }
    }
    @IBOutlet weak var categoryLabel: UILabel! {
        didSet {
            theme.apply(.info, toLabel: categoryLabel)
        }
    }
    
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

        titleLabel.text = project?.name
        
        let manager = SDWebImageManager.shared
        manager.loadImage(with: context.imageURLs.first, options: [], progress: nil) { [weak self] (image, data, error, cachType, finished, url) in
            guard let size = image?.proportionalScaledSize(using: UIScreen.main.bounds.size.width) else {
                return log.w("Failed to get proportional image size")
            }
            self?.imageView.image = image?.resizedImage(using: size)
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
        authorLabel.text = project.author.name
        progressView.progress = fundedPercent
        locationLabel.text = project.country
        blurbLabel.text = project.blurb
        if project.videoUrl != nil {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.playVideoButton.isHidden = false
            }
        }
        else {
            playVideoButton.isHidden = true
        }
    }
}
