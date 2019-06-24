/**

 @copyright 2017 Upstart Illustration LLC. All rights reserved.
 */

import Foundation
import SpriteKit

class Action {
    private var actions: [SKAction] = []
    
    static func group(_ actions: Action...) -> Action {
        return Action().group(actions)
    }
    
    static func sequence(_ actions: Action...) -> Action {
        return Action().sequence(actions)
    }
    
    static func action(_ action: SKAction) -> Action {
        return Action().action(action)
    }
    
    static func fadeIn(duration: TimeInterval) -> Action {
        return Action().fadeIn(duration: duration)
    }
    
    static func fadeOut(duration: TimeInterval) -> Action {
        return Action().fadeOut(duration: duration)
    }
    
    static func move(to point: CGPoint, duration: TimeInterval) -> Action {
        return Action().move(to: point, duration: duration)
    }
    
    static func scale(to amount: CGFloat, duration: TimeInterval) -> Action {
        return Action().scale(to: amount, duration: duration)
    }
    
    static func scale(by amount: CGFloat, duration: TimeInterval, reversed: Bool = false) -> Action {
        return Action().scale(by: amount, duration: duration, reversed: reversed)
    }
    
    static func wait(duration: TimeInterval) -> Action {
        return Action().wait(duration: duration)
    }
    
    static func run(_ callback: @escaping () -> Void) -> Action {
        return Action().run(callback)
    }
    
    static func z(_ zPosition: CGFloat, on node: SKNode) -> Action {
        return Action().z(zPosition, on: node)
    }
    
    static func remove() -> Action {
        return Action().remove()
    }
    
    func action(_ action: SKAction) -> Action {
        actions.append(action)
        return self
    }
    
    func fadeIn(duration: TimeInterval) -> Action {
        let action = SKAction.fadeIn(withDuration: duration)
        actions.append(action)
        return self
    }
    
    func fadeOut(duration: TimeInterval) -> Action {
        let action = SKAction.fadeOut(withDuration: duration)
        actions.append(action)
        return self
    }
    
    func move(to point: CGPoint, duration: TimeInterval) -> Action {
        let action = SKAction.move(to: point, duration: duration)
        actions.append(action)
        return self
    }
    
    func scale(to amount: CGFloat, duration: TimeInterval) -> Action {
        let action = SKAction.scale(to: amount, duration: duration)
        actions.append(action)
        return self
    }
    
    func scale(by amount: CGFloat, duration: TimeInterval, reversed: Bool = false) -> Action {
        let action = SKAction.scale(by: amount, duration: duration)
        if reversed {
            actions.append(action.reversed())
        }
        else {
            actions.append(action)
        }
        return self
    }
    
    func wait(duration: TimeInterval) -> Action {
        let action = SKAction.wait(forDuration: duration)
        actions.append(action)
        return self
    }
    
    func run(_ callback: @escaping () -> Void) -> Action {
        let action = SKAction.run(callback)
        actions.append(action)
        return self
    }
    
    func z(_ zPosition: CGFloat, on node: SKNode) -> Action {
        let action = SKAction.run { node.zPosition = zPosition }
        actions.append(action)
        return self
    }
    
    func remove() -> Action {
        let action = SKAction.removeFromParent()
        actions.append(action)
        return self
    }
    
    func group(_ actions: [Action]) -> Action {
        var allActions: [SKAction] = []
        for action in actions {
            allActions.append(contentsOf: action.actions)
        }
        let action = SKAction.group(allActions)
        self.actions.append(action)
        return self
    }
    
    func group(_ actions: Action...) -> Action {
        return self.group(actions)
    }
    
    func sequence(_ actions: [Action]) -> Action {
        var allActions: [SKAction] = []
        for action in actions {
            allActions.append(contentsOf: action.actions)
        }
        let action = SKAction.sequence(allActions)
        self.actions.append(action)
        return self
    }
    
    func make() -> SKAction {
        if actions.count == 1 {
            return actions[0]
        }
        return SKAction.sequence(actions)
    }
}

