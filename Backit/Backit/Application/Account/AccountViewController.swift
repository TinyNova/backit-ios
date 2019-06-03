import Foundation
import UIKit

class AccountViewController: UITableViewController {
    
    private var userStream: UserStreamer?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        tabBarItem = UITabBarItem(title: nil, image: emptyProfileImage(), tag: 9999)
    }
    
    func inject(userStream: UserStreamer) {
        userStream.listen(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "My Account"
        tabBarItem?.title = nil
    }
    
    private func avatarImage() -> UIImage? {
        return nil
    }
    
    private func emptyProfileImage() -> UIImage? {
        guard let image = UIImage(named: "empty-profile")?
            .fittedImage(to: 22.0)?
            .sd_tintedImage(with: UIColor.fromHex(0xffffff))?
            .withRenderingMode(.alwaysOriginal) else {
            return nil
        }

        return ellipticalAvatar(with: image)
    }
    
    private func ellipticalAvatar(with image: UIImage) -> UIImage? {
        let size = CGSize(width: 30, height: 30)
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        
        // Background circle
        let bgRect = CGRect(x: 0, y: 0, width: 30, height: 30)
        context?.setFillColor(UIColor.fromHex(0xa7a9bc).cgColor)
        context?.addEllipse(in: bgRect)
        context?.drawPath(using: .fill)
        
        // Circle the avatar image to fit inside the background circle
        let avatarRect = CGRect(x: 4, y: 4, width: 22, height: 22)
        let bezierPath = UIBezierPath(roundedRect: avatarRect, byRoundingCorners: [.allCorners], cornerRadii: CGSize(width: 11.0, height: 11.0))
        context?.addPath(bezierPath.cgPath)
        context?.clip()
        context?.drawPath(using: .fillStroke)
        context?.draw(image.cgImage!, in: avatarRect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage?.withRenderingMode(.alwaysOriginal)
    }
}

extension AccountViewController: UserStreamListener {
    func didChangeUser(_ user: User) {
        // TODO: Update the avatar image in the tab bar icon
    }
}
