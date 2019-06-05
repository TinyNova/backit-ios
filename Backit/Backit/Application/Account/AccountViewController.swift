import Foundation
import UIKit

class AccountViewController: UITableViewController {
    
    private var urlSession: URLSession?
    private var userStream: UserStreamer?
    private var signInProvider: SignInProvider?
    private var albumProvider: PhotoAlbumProvider?
    private var accountProvider: AccountProvider?
    
    private var loggedIn: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        updateTabBar(with: emptyProfileImage())
    }
    
    func inject(urlSession: URLSession, userStream: UserStreamer, signInProvider: SignInProvider, albumProvider: PhotoAlbumProvider, accountProvider: AccountProvider) {
        self.urlSession = urlSession
        self.signInProvider = signInProvider
        self.albumProvider = albumProvider
        self.accountProvider = accountProvider
        userStream.listen(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "My Account"
        tabBarItem?.title = nil
    }

    private func updateTabBar(with image: UIImage?) {
        let item = UITabBarItem(title: nil, image: image, tag: 9999)
        item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        tabBarItem = item
    }
    
    private func emptyProfileImage() -> UIImage? {
        let image = UIImage(named: "empty-profile")?
            .fittedImage(to: 22.0)?
            .sd_tintedImage(with: UIColor.fromHex(0xffffff))?
            .withRenderingMode(.alwaysOriginal)

        return ellipticalAvatar(with: image)
    }
    
    private func ellipticalAvatar(with image: UIImage?) -> UIImage? {
        guard let image = image else {
            return nil
        }
        
        let points: CGFloat = 32.0
        
        let size = CGSize(width: points, height: points)
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        
        // Background circle
        let bgRect = CGRect(x: 0, y: 0, width: points, height: points)
        context?.setFillColor(UIColor.fromHex(0xa7a9bc).cgColor)
        context?.addEllipse(in: bgRect)
        context?.drawPath(using: .fill)
        
        // Clip avatar image as circle to fit inside the background circle
        let avatarRect = CGRect(x: 2, y: 2, width: 28, height: 28)
        let bezierPath = UIBezierPath(roundedRect: avatarRect, byRoundingCorners: [.allCorners], cornerRadii: CGSize(width: 14.0, height: 14.0))
        context?.addPath(bezierPath.cgPath)
        context?.clip()
        image.draw(in: avatarRect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage?.withRenderingMode(.alwaysOriginal)
    }
}

extension AccountViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseIdentifier") {
            configureCell(cell, at: indexPath)
            return cell
        }
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ReuseIdentifier")
        configureCell(cell, at: indexPath)
        return cell
    }
    
    private func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Upload a picture"
            cell.detailTextLabel?.text = loggedIn ? nil : "Sign in to upload your avatar"
        case 1:
            cell.textLabel?.text = loggedIn ? "Sign out" : "Sign In"
        default:
            break
        }
    }
}

extension AccountViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            guard loggedIn else {
                print("Error: Can not upload an avatar when logged out")
                return
            }
            
            albumProvider?.requestImage { [weak self] (image, error) in
                guard let image = image else {
                    return print("Error: \(String(describing: error))")
                }
                guard let avatarImage = self?.ellipticalAvatar(with: image) else {
                    return print("Failed to create avatar")
                }

                // TODO: Animate change
                self?.updateTabBar(with: avatarImage)

//                self?.accountProvider?.uploadAvatar(image: image)
//                    .onSuccess { _ in
//                        print("Successfully uploaded the avatar")
//                    }
//                    .onFailure { (error) in
//                        print("Failed to upload the avatar: \(String(describing: error))")
//                    }
            }
        case 1:
            if loggedIn {
                signInProvider?.logout().onSuccess { [weak self] _ in
                    self?.tableView.reloadData()
                }
            }
            else {
                signInProvider?.login().onSuccess { [weak self] userSession in
                    self?.tableView.reloadData()
                }
            }
        default:
            break
        }
    }
}

extension AccountViewController: UserStreamListener {
    func didChangeUser(_ user: User?) {
        loggedIn = user != nil
        tableView.reloadData()
        
        guard let avatarUrl = user?.avatarUrl else {
            return
        }
        
        urlSession?.dataTask(with: avatarUrl) { [weak self] (data, response, error) in
            guard error == nil,
                let data = data,
                let image = UIImage(data: data),
                let avatarImage = self?.ellipticalAvatar(with: image) else {
                return
            }
            
            DispatchQueue.main.async {
                self?.tabBarItem.image = avatarImage
            }
        }
    }
}
