/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

import BKFoundation

class AccountViewController: UITableViewController {
    
    private var urlSession: URLSession?
    private var userStream: UserStreamer?
    private var avatarStream: UserAvatarStreamer?
    private var signInProvider: SignInProvider?
    private var albumProvider: PhotoAlbumProvider?
    private var accountProvider: AccountProvider?
    private var overlay: ProgressOverlayProvider?
    
    private var user: User?

    private var isLoggedIn: Bool {
        guard let user = user else {
            return false
        }
        return !user.isGuest
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setEmptyAvatar()
    }
    
    func inject(urlSession: URLSession, userStream: UserStreamer, avatarStream: UserAvatarStreamer, signInProvider: SignInProvider, albumProvider: PhotoAlbumProvider, accountProvider: AccountProvider, overlay: ProgressOverlayProvider) {
        self.urlSession = urlSession
        self.signInProvider = signInProvider
        self.albumProvider = albumProvider
        self.accountProvider = accountProvider
        self.overlay = overlay
        userStream.listen(self)
        avatarStream.listen(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "My Account"
        tabBarItem?.title = nil
    }

    private func updateTabBar(image: UIImage?, selectedImage: UIImage?) {
        let item = UITabBarItem(title: nil, image: image, selectedImage: selectedImage)
        item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        tabBarItem = item
    }
    
    private func setEmptyAvatar() {
        let image = UIImage(named: "avatar")?
            .fittedImage(to: 22.0)?
            .sd_tintedImage(with: UIColor.fromHex(0xffffff))?
            .withRenderingMode(.alwaysOriginal)

        setAvatar(with: image)
    }
    
    private func setAvatar(with image: UIImage?) {
        guard let image = image else {
            log.i("Attempt to set an avatar with a `nil` `UIImage`")
            return
        }

        let icon = ellipticalImage(with: image, color: UIColor.fromHex(0xa7a9bc))
        let selectedIcon = ellipticalImage(with: image, color: UIColor.fromHex(0x130a33))
        updateTabBar(image: icon, selectedImage: selectedIcon)
    }

    func ellipticalImage(with image: UIImage, color: UIColor) -> UIImage? {
        let points: CGFloat = 32.0

        let size = CGSize(width: points, height: points)
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()

        // Background circle
        let bgRect = CGRect(x: 0, y: 0, width: points, height: points)
        context?.setFillColor(color.cgColor)
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
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell") {
            configureCell(cell, at: indexPath)
            return cell
        }
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "AccountCell")
        configureCell(cell, at: indexPath)
        return cell
    }
    
    private func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Upload a picture"
            cell.detailTextLabel?.text = isLoggedIn ? nil : "Sign in to upload your avatar"
        case 1:
            guard let user = user, isLoggedIn else {
                cell.textLabel?.text = "Sign In"
                cell.detailTextLabel?.text = nil
                return
            }
            cell.textLabel?.text = "Sign out"
            cell.detailTextLabel?.text = "Signed in as \(user.username)"
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
            guard isLoggedIn else {
                log.e("Can not upload an avatar when logged out")
                return
            }
            
            overlay?.show()
            albumProvider?.requestImage { [weak self] (image, error) in
                guard let image = image else {
                    self?.overlay?.dismiss()
                    return log.e(String(describing: error))
                }

                self?.accountProvider?.uploadAvatar(image: image)
                    .onSuccess { _ in
                        log.i("Successfully uploaded the avatar")
                    }
                    .onFailure { (error) in
                        log.e("Failed to upload the avatar: \(String(describing: error))")
                    }
                    .onComplete { [weak self] _ in
                        self?.overlay?.dismiss()
                    }
            }
        case 1:
            // `UserStreamListener` will handle the login/logout events.
            if isLoggedIn {
                overlay?.show()
                signInProvider?.logout().onComplete { [weak self] _ in
                    self?.overlay?.dismiss()
                }
            }
            else {
                _ = signInProvider?.login()
            }
        default:
            break
        }
    }
}

extension AccountViewController: UserStreamListener {
    func didChangeUser(_ user: User) {
        self.user = user
        tableView.reloadData()
        
        guard let avatarUrl = user.avatarUrl else {
            return setEmptyAvatar()
        }
        
        let task = urlSession?.dataTask(with: avatarUrl) { [weak self] (data, response, error) in
            guard error == nil,
                let data = data,
                let image = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.setAvatar(with: image)
            }
        }
        task?.resume()
    }
}

extension AccountViewController: UserAvatarStreamListener {
    
    func didChangeAvatar(_ image: UIImage?, state: UserAvatarStreamState) {
        guard let image = image else {
            return log.i("Avatar is empty")
        }
        // This prevents double drawing of image.
        guard state == .uploading || state == .cached else {
            return log.i("Ignoring any avatar state except `uploading` and `cached`")
        }
        
        // TODO: Animate the image.
        DispatchQueue.main.async { [weak self] in
            self?.setAvatar(with: image)
        }
    }
}
