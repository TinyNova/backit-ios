import Foundation
import UIKit

extension UITabBarItem {
    static func tabBarItem(using imageName: String) -> UITabBarItem? {
        let icon = UIImage(named: imageName)?
            .fittedImage(to: 40)?
            .sd_tintedImage(with: UIColor.fromHex(0xa7a9bc))?
            .withRenderingMode(.alwaysOriginal)
        let tabBarItem = UITabBarItem(title: nil, image: icon, selectedImage: icon)
        tabBarItem.imageInsets = UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0)
        return tabBarItem
    }
}
