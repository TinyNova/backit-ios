/**
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import SpriteKit

import BKFoundation

class ProgressOverlayScene: SKScene {
    
    private var gerbil: SKNode?
    
    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.0, y: 0.0)
        backgroundColor = .clear
        scaleMode = .aspectFill
        
        createGerbilIfNeeded()
        animateGerbil()
    }
    
    private func animateGerbil() {
        guard let gerbil = gerbil else {
            return log.w("`gerbil` must be created first")
        }
        
        let size = UIScreen.main.bounds.size
        gerbil.position = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
        gerbil.run(SKAction.repeatForever(SKAction.rotate(byAngle: -3.14/2, duration: 0.1)))
    }
    
    private func createGerbilIfNeeded() {
        guard gerbil == nil else {
            return
        }
        
        let gerbil = SKShapeNode(circleOfRadius: 20.0)
        gerbil.fillColor = .red
        let dot = SKShapeNode(circleOfRadius: 1.0)
        dot.fillColor = .black
        dot.position = CGPoint(x: 10.0, y: 0.0)
        gerbil.addChild(dot)
        
        self.gerbil = gerbil
        addChild(gerbil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return log.i("no `touches`")
        }
        
        let location = touch.location(in: self)

        print("Touched at: \(location)")
    }
}
