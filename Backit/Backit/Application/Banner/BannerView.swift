import Foundation
import SpriteKit

protocol BannerViewDelegate: class {
    func didDismissBanner(_ bannerView: BannerView)
}

class BannerView: SKView {
    
    var bannerDelegate: BannerViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        ignoresSiblingOrder = false
        backgroundColor = UIColor.clear
        allowsTransparency = true
    }
    
    @objc private func didTapBanner(_ sender: Any?) {
        log.i("Did tap to dismiss the banner")
    }
    
    func show(message: BannerMessage) {
        let scene = BannerScene(size: frame.size)
        scene.configure(message: message) { [weak self] (button: BannerButton?) in
            guard let sself = self else {
                return
            }
            if let button = button {
                button.callback()
            }
            sself.bannerDelegate?.didDismissBanner(sself)
        }
        presentScene(scene)
    }
    
    func dismiss() {
        
    }
}
