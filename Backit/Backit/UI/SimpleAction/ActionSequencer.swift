/**
 Provides a way to run several `SKAction`s in a sequence.
 
 There is a risk that if a node gets removed from a parent that the animation will _not_ fire the completion block. One way to mitigate this is to use a `DispatchGroup` in coordination with this class, where a block action is called directly before actions which will destory nodes within a sequence. I do not know if this will pre-maturely terminate actions that came after this node.
 
 @copyright 2017 Upstart Illustration LLC. All rights reserved.
 */

import Foundation
import SpriteKit

class ActionSequencer {
    
    private let root: SKNode
    
    private var queue: [SKAction] = []
    private var asyncTimes: [TimeInterval] = []
    private var totalTime: TimeInterval = 0.0
    
    init(root: SKNode) {
        self.root = root
    }
    
    func addAction(_ action: Action, to node: SKNode) {
        finalizeGroupActions()
        addAction(action.make(), to: node)
    }
    
    func addAction(_ action: SKAction, to node: SKNode) {
        finalizeGroupActions()
        
        let run = SKAction.run { node.run(action) }
        let sequence = SKAction.sequence([SKAction.wait(forDuration: totalTime), run])
        queue.append(sequence)
        totalTime += action.duration
    }
    
    func runBlockOn(_ node: SKNode, block: @escaping () -> Void) {
        addAction(SKAction.run(block), to: node)
    }
    
    // Maybe there should be an `addGroup` and an `addAsyncAction`. The async action would not manage time.
    
    @discardableResult
    func groupAction(_ action: Action, to node: SKNode, manageTime: Bool = true) -> TimeInterval {
        return groupAction(action.make(), to: node, manageTime: manageTime)
    }
    
    @discardableResult
    func groupAction(_ action: SKAction, to node: SKNode, manageTime: Bool = true) -> TimeInterval {
        let run = SKAction.run { node.run(action) }
        let sequence = SKAction.sequence([SKAction.wait(forDuration: totalTime), run])
        queue.append(sequence)
        let duration = action.duration
        if manageTime {
            asyncTimes.append(duration)
        }
        return duration
    }
    
    /**
     Add a delay to the animation sequence.
     
     In most cases this should _not_ be necessary as async actions are ran in sequence. In some special cases it is necessary.
     */
    func addDelay(_ duration: TimeInterval) {
        totalTime += duration
    }
    
    func play() {
        finalizeGroupActions()
        root.run(SKAction.group(queue))
    }
    
    /**
     Adds the longest duration of the grouped actions to the total time.
     */
    private func finalizeGroupActions() {
        guard asyncTimes.count > 0 else {
            return
        }
        
        let duration = asyncTimes.reduce(TimeInterval(0.0), { (result, time) -> TimeInterval in
            return result > time ? result : time
        })
        totalTime += duration
        asyncTimes = []
    }
}
