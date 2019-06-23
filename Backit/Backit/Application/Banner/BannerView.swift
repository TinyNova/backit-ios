import Foundation
import SpriteKit

protocol BannerViewDelegate: class {
    func didDismissBanner(_ bannerView: BannerView)
}

class BannerView: SKView {
    
    private var showing: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        self.ignoresSiblingOrder = false
    }
    
    func show(message: BannerMessage) {
        guard !showing else {
            log.w("Showing `BannerView` more than once")
            return
        }
        
        showing = true
        
        let scene = BannerScene(size: frame.size)
        scene.configure(message: message)
        presentScene(scene)
    }
}
