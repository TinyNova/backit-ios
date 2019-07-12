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
    
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            theme.apply(.feedProjectName, toLabel: titleLabel)
        }
    }
    
    private let theme: UIThemeApplier<AppTheme> = AppTheme.default

    private var project: FeedProject?
    
    func configure(with project: FeedProject) {
        self.project = project
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
    }
    
    @objc func didTapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
