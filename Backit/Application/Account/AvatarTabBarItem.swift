/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

class AvatarTabBarItem: UITabBarItem {
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        setup()
    }
    
    func configure(avatarUrl: URL?) {
        guard let avatarUrl = avatarUrl else {
            avatarImageView.image = emptyProfilePic()
            return
        }
        
//        let URL(string: "https://s3.amazonaws.com/backit.com/img/test/eric-250.jpg")!

        avatarImageView.sd_setImage(with: avatarUrl) { [weak self] (image, error, cacheType, url) in
            let avatarImage = image?.fittedImage(to: 30.0)
            self?.avatarImageView.image = avatarImage
        }
    }
    
    private func emptyProfilePic() -> UIImage? {
        return UIImage(named: "empty-profile")?
            .fittedImage(to: 30.0)?
            .sd_tintedImage(with: UIColor.white)
    }
}
