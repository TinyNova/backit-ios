/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit

@objc class AppPhotoAlbumProvider: NSObject, UINavigationControllerDelegate, PhotoAlbumProvider {
    
    let presenterProvider: PresenterProvider

    init(presenterProvider: PresenterProvider) {
        self.presenterProvider = presenterProvider
    }
    
    var callback: ((UIImage?, PhotoAlbumProviderError?) -> Void)?
    
    func requestImage(callback: @escaping (UIImage?, PhotoAlbumProviderError?) -> Void) {
        guard UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) else {
            return callback(nil, .noPermission)
        }
        
        self.callback = callback
        
        DispatchQueue.main.async { [weak self] in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            
            self?.presenterProvider.present(imagePicker, completion: nil)
        }
    }
}

extension AppPhotoAlbumProvider: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        presenterProvider.dismiss(picker) { [weak self] in
            guard let image = info[.originalImage] as? UIImage else {
                self?.callback?(nil, .didNotSelectValidMedia)
                return
            }
            self?.callback?(image, nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        presenterProvider.dismiss(picker) { [weak self] in
            self?.callback?(nil, .userCancelled)
        }
    }
}
