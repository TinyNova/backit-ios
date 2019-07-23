/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

extension UITabBarItem {
    static func tabBarItem(using imageName: String) -> UITabBarItem? {
        let icon = UIImage(named: imageName)?
            .fittedImage(to: 40)?
            .sd_tintedImage(with: UIColor.fromHex(0xa7a9bc))?
            .withRenderingMode(.alwaysOriginal)
        let selectedIcon = UIImage(named: imageName)?
            .fittedImage(to: 40)?
            .sd_tintedImage(with: UIColor.fromHex(0x130a33))?
            .withRenderingMode(.alwaysOriginal)
        let tabBarItem = UITabBarItem(title: nil, image: icon, selectedImage: icon)
        tabBarItem.selectedImage = selectedIcon
        tabBarItem.imageInsets = UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0)
        return tabBarItem
    }
}
