import Foundation
import SpriteKit

class BannerScene: SKScene {
    
    private var message: BannerMessage?
    
    public func configure(message: BannerMessage) {
        self.message = message
    }
    
    override func didMove(to view: SKView) {
        let width = UIScreen.main.bounds.size.width
        let banner = SKShapeNode(rect: CGRect(x: 0, y: 0, width: width, height: width / 2.0), cornerRadius: 5.0)
        banner.fillColor = UIColor.fromHex(0xffffff)
        
        let title = SKLabelNode(text: message?.title)
        title.fontColor = UIColor.fromHex(0x000000)
        title.fontName = "AcuminPro-Bold"
        title.fontSize = 14.0
        title.position = CGPoint(x: 5, y: 5)
        banner.addChild(title)
        
        let description = SKLabelNode(text: message?.message)
        description.fontColor = UIColor.fromHex(0x000000)
        description.fontName = "AcuminPro-Regular"
        description.fontSize = 14.0
        description.position = CGPoint(x: 5, y: 15)
        banner.addChild(description)
        
        addChild(banner)
    }
}
