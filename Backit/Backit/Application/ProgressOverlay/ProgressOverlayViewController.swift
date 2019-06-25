/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import UIKit
import SpriteKit

class ProgressOverlayViewController: UIViewController {
    
    private var isFullscreen: Bool = false
    private var scene: ProgressOverlayScene?
    
    @IBOutlet weak var spriteKitView: SKView! {
        didSet {
            spriteKitView.backgroundColor = .clear
            spriteKitView.allowsTransparency = true
        }
    }
    
    func prepareForModalPresentation(fullScreen: Bool) {
        isFullscreen = fullScreen
        if fullScreen {
            modalPresentationStyle = .overFullScreen
        }
        else {
            modalPresentationStyle = .overCurrentContext
        }
        view.backgroundColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scene = ProgressOverlayScene(size: view.frame.size)
        spriteKitView.presentScene(scene)
    }
}
