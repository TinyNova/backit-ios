/**
 * Gaussian blur:
 * https://stackoverflow.com/questions/41120721/how-to-show-shadow-or-any-glow-effect-for-skspritenode-when-it-moved-on-screen-o
 */
import Foundation
import SpriteKit

private class ButtonNode: SKNode {
    var tag: Int = 0
}

typealias BannerSceneCallback = (_ tappedButton: BannerButton?) -> Void

class BannerScene: SKScene {
    
    private var message: BannerMessage?
    private var callback: BannerSceneCallback?
    
    private lazy var sequencer: ActionSequencer = {
        return ActionSequencer(root: self)
    }()
    
    private var banner: SKNode?
    private var startPosition: CGPoint?
    private var finalPosition: CGPoint?
    
    public func configure(message: BannerMessage, callback: @escaping BannerSceneCallback) {
        self.message = message
        self.callback = callback
    }
    
    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.0, y: 0.0)
        backgroundColor = .clear
//        backgroundColor = .gray
        scaleMode = .aspectFill
        
        createBannerIfNeeded()
        animateBanner()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return log.i("no `touches`")
        }
        
        let location = touch.location(in: self)
        let nodes: [SKNode] = self.nodes(at: location)
        
        guard let button = nodes.first(where: { (node) -> Bool in
            return node is ButtonNode
        }) as? ButtonNode else {
            callback?(nil)
            return
        }
        
        log.i("Tapped button \(button)")
        switch button.tag {
        case 0:
            callback?(message?.button1)
        case 1:
            callback?(message?.button2)
        default:
            log.w("A button was tapped with unknonw tag \(button.tag)")
            callback?(nil)
        }
    }
    
    private func animateBanner() {
        guard let banner = banner,
              let startPosition = startPosition,
              let finalPosition = finalPosition else {
            return log.w("Failed to animate `banner`")
        }
        
        banner.alpha = 0.0
        banner.position = startPosition
        
        let fadeIn = Action.fadeIn(duration: 0.3)
        let move = Action.move(to: finalPosition, duration: 0.3)
        let group = Action.group(fadeIn, move)
        sequencer.addAction(group, to: banner)
        sequencer.play()
    }
    
    private func createBannerIfNeeded() {
        guard banner == nil else {
            return
        }
        
        let screenWidth = UIScreen.main.bounds.size.width
        let width = screenWidth - 80.0 // This value / 2 = amount of space on each side
        let height = width / 2.0 // TODO
        
        let banner = SKNode()

        let shadow = SKShapeNode(rect: CGRect(x: 5, y: -5, width: width, height: height), cornerRadius: 10.0)
        shadow.fillColor = .black
        shadow.strokeColor = .clear
        shadow.alpha = 0.3
        banner.addChild(shadow)
        
        let bannerBg = SKShapeNode(rect: CGRect(x: 0, y: 0, width: width, height: height), cornerRadius: 10.0)
        bannerBg.fillColor = UIColor.fromHex(0xffffff)
        bannerBg.strokeColor = .gray
        banner.addChild(bannerBg)
        
        let x: CGFloat = 60.0
        
        let messageType: BannerType = message?.type ?? .error
        let messageColor: UIColor
        let messageImage: String
        switch messageType {
        case .error:
            messageImage = "warning"
            messageColor = UIColor.fromHex(0xff0000)
        case .info:
            messageImage = "info"
            messageColor = UIColor.fromHex(0x0000ff)
        case .warning:
            messageImage = "warning"
            messageColor = UIColor.fromHex(0xffff00)
        }
        
        let image = UIImage(named: messageImage)?
            .fittedImage(to: 38.0)?
            .sd_tintedImage(with: messageColor)?
            .withRenderingMode(.alwaysOriginal)
        if let image = image {
            log.w("Failed to load image \(messageImage)")
            let imageNode = SKSpriteNode(texture: SKTexture(image: image))
            imageNode.position = CGPoint(x: 30.0, y: height - 30.0)
            bannerBg.addChild(imageNode)
        }
        
        let title = SKLabelNode(text: message?.title)
        title.fontColor = UIColor.fromHex(0x000000)
        title.fontName = "AcuminPro-Bold"
        title.fontSize = 20.0
        title.position = CGPoint(x: x, y: height - 38.0)
        title.horizontalAlignmentMode = .left
        bannerBg.addChild(title)
        
        let description = SKLabelNode(text: message?.message)
        description.fontColor = UIColor.fromHex(0x000000)
        description.fontName = "AcuminPro-Regular"
        description.fontSize = 16.0
        description.numberOfLines = 0
        description.lineBreakMode = .byWordWrapping
        description.preferredMaxLayoutWidth = width - x - 10.0 // width of full box - x adjust - 10 for padding
        description.position = CGPoint(x: x, y: title.position.y - 14.0)
        description.horizontalAlignmentMode = .left
        description.verticalAlignmentMode = .top
        bannerBg.addChild(description)

        addChild(banner)
        
        self.banner = banner
        
        let bannerX: CGFloat = ceil((screenWidth - width) / 2.0)
        let screenHeight = UIScreen.main.bounds.size.height - 60.0
        self.startPosition = CGPoint(x: bannerX, y: screenHeight - height)
        self.finalPosition = CGPoint(x: bannerX, y: screenHeight - height - 10.0)
    }
}
