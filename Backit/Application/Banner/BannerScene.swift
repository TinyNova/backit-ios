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
    
    private var playBannerAnimation: (() -> Void)?
    private var playArmAnimation: (() -> Void)?
    
    var paddingTop: CGFloat = 0.0
    
    public func configure(message: BannerMessage, callback: @escaping BannerSceneCallback) {
        self.message = message
        self.callback = callback
    }
    
    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.0, y: 0.0)
        backgroundColor = .clear
//        backgroundColor = .gray
        scaleMode = .aspectFill
        
        createSpritesIfNeeded()
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
    
    private func createSpritesIfNeeded() {
        guard playArmAnimation == nil else {
            return
        }
        
        let banner = makeBanner()
        // TODO: Eventually put the banner behind the fingers.
        addChild(banner)
        
        let atlas = SKTextureAtlas(named: "robot-arm")
        func sprite(for name: String, at position: CGPoint) -> SKSpriteNode {
            let texture = atlas.textureNamed(name)
            return SKSpriteNode(texture: texture)
        }
        func textures(for name: String, _ numFrames: Int) -> [SKTexture] {
            var textures = [SKTexture]()
            for i in 0..<numFrames {
                let textureName = "\(name)-\(i)"
                let texture = atlas.textureNamed(textureName)
                textures.append(texture)
            }
            return textures
        }
        
        let arm = SKNode()
        // 0-3 grab, 4-6 "loose" grab
        let fingerFrames = textures(for: "lhand", 7)
        let thumbFrames = textures(for: "rhand", 7)
        let thumb = SKSpriteNode(texture: thumbFrames.first)
        thumb.position = CGPoint(x: -3.0, y: -150.0)
        arm.addChild(thumb)
        arm.addChild(SKSpriteNode(texture: atlas.textureNamed("arm")))
//        arm.addChild(banner)
        let fingers = SKSpriteNode(texture: fingerFrames.first)
        fingers.position = CGPoint(x: -1.0, y: -150.0)
        arm.addChild(fingers)
        
        arm.xScale = 0.25
        arm.yScale = 0.25
        let top = UIScreen.main.bounds.size.height
        arm.position = CGPoint(x: 150.0, y: top - 10)
        let moveDown = SKAction.move(to: CGPoint(x: 150.0, y: top - 40.0), duration: 0.1)
        let moveUp = SKAction.move(to: CGPoint(x: 150.0, y: top), duration: 0.1)
        let openFrames: [SKTexture] = [
            fingerFrames[5],
            fingerFrames[4],
            fingerFrames[3]
        ]
        let openFrames2: [SKTexture] = [
            thumbFrames[5],
            thumbFrames[4],
            thumbFrames[3]
        ]
        let fingersAnim = SKAction.animate(with: openFrames, timePerFrame: 0.1)
        let thumbAnim = SKAction.animate(with: openFrames2, timePerFrame: 0.1)
        
        addChild(arm)
        
        playArmAnimation = {
            let sequencer = ActionSequencer(root: self)
            sequencer.addAction(moveDown, to: arm)
            sequencer.groupAction(fingersAnim, to: fingers)
            sequencer.groupAction(thumbAnim, to: thumb)
            sequencer.addAction(moveUp, to: arm)
            sequencer.play()
        }
    }
    
    private func animateBanner() {
        guard let animateBanner = playBannerAnimation,
              let animateArm = playArmAnimation else {
            return log.w("Failed to animate `banner`")
        }
        
        animateBanner()
        animateArm()
    }
    
    private func makeBanner() -> SKNode {
        let screenWidth = UIScreen.main.bounds.size.width
        let width = screenWidth > 720 ? 700 : screenWidth - 20.0
        
        let banner = SKNode()

        let title = SKLabelNode(text: message?.title)
        title.fontColor = UIColor.fromHex(0x000000)
        title.fontName = "AcuminPro-Bold"
        title.fontSize = 18.0
        title.horizontalAlignmentMode = .left

        let description = SKLabelNode(text: message?.message)
        description.fontColor = UIColor.fromHex(0x000000)
        description.fontName = "AcuminPro-Regular"
        description.fontSize = 16.0
        description.numberOfLines = 0
        description.lineBreakMode = .byWordWrapping
        description.preferredMaxLayoutWidth = width - 30.0
        description.horizontalAlignmentMode = .left
        description.verticalAlignmentMode = .top
        log.i("description height: \(description.frame.size.height)")

        let height: CGFloat = 60.0 + description.frame.size.height + 10.0
        
        let shadow = SKShapeNode(rect: CGRect(x: 5, y: -5, width: width, height: height), cornerRadius: 10.0)
        shadow.fillColor = .black
        shadow.strokeColor = .clear
        shadow.alpha = 0.3
        banner.addChild(shadow)
        
        let bannerBg = SKShapeNode(rect: CGRect(x: 0, y: 0, width: width, height: height), cornerRadius: 10.0)
        bannerBg.fillColor = UIColor.fromHex(0xffffff)
        bannerBg.strokeColor = .gray
        banner.addChild(bannerBg)
        
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
        
        title.position = CGPoint(x: 60.0, y: height - 38.0)
        bannerBg.addChild(title)
        
        description.position = CGPoint(x: 20.0, y: title.position.y - 20.0)
        bannerBg.addChild(description)
        
        let bannerX: CGFloat = ceil((screenWidth - width) / 2.0)
        let screenHeight = UIScreen.main.bounds.size.height - paddingTop
        let startPosition = CGPoint(x: bannerX, y: screenHeight - height)
        let finalPosition = CGPoint(x: bannerX, y: screenHeight - height - 10.0)
        
        playBannerAnimation = {
            banner.alpha = 0.0
            banner.position = startPosition
            
            let fadeIn = Action.fadeIn(duration: 0.3)
            let move = Action.move(to: finalPosition, duration: 0.3)
            let group = Action.group(fadeIn, move)
            let seq = ActionSequencer(root: self)
            seq.addAction(group, to: banner)
            seq.play()
        }

        return banner
    }
}
