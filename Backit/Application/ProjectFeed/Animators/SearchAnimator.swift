import Foundation
import UIKit

class SearchAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var originFrame: CGRect = .zero
    var dismissCompletion: (() -> Void)?
    
    private let duration: TimeInterval = 0.33
    private var finalFrame: CGRect = .zero

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toController = transitionContext.viewController(forKey: .to) else {
            return
        }
        if toController.isBeingPresented {
            animatePresent(transitionContext)
        }
        else {
            animateDismiss(transitionContext)
        }
    }
    
    private func animatePresent(_ transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let feedController = transitionContext.viewController(forKey: .from) as? ProjectFeedViewController,
              let searchView = transitionContext.view(forKey: .to),
              let searchController = transitionContext.viewController(forKey: .to) as? SearchViewController else {
            return print("Failed to get `SearchViewController` from `transitionContext`")
        }
        
        let searchIconView = UIImageView(image: feedController.searchImageView.screenshot())
        searchIconView.frame = originFrame
        
        searchController.cancelButton.alpha = 0.0
        searchController.searchIconView.alpha = 0.0
        
        containerView.addSubview(searchView)
        containerView.addSubview(searchIconView)
        containerView.bringSubviewToFront(searchView)
        containerView.bringSubviewToFront(searchIconView)
        
        var finalFrame = searchController.searchIconView.frame
        finalFrame.origin.y = UIApplication.shared.statusBarFrame.size.height
        self.finalFrame = finalFrame
        
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.0,
            animations: {
                searchController.cancelButton.alpha = 1.0
                searchIconView.frame = finalFrame
            },
            completion: { _ in
                searchController.searchIconView.alpha = 1.0
                searchIconView.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        )
    }
    
    private func animateDismiss(_ transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let feedController = transitionContext.viewController(forKey: .to) as? ProjectFeedViewController,
              let searchController = transitionContext.viewController(forKey: .from) as? SearchViewController else {
            return print("Failed to get `ProjectFeedViewController` from `transitionContext`")
        }
        
        let searchIconView = UIImageView(image: feedController.searchImageView.screenshot())
        searchIconView.frame = finalFrame
                
        if let toView = transitionContext.view(forKey: .to) {
            containerView.addSubview(toView)
        }

        containerView.addSubview(searchIconView)
        containerView.bringSubviewToFront(searchIconView)
        
        searchController.searchIconView.alpha = 0.0
        searchController.cancelButton.alpha = 0.0
        feedController.searchImageView.alpha = 0.0

        let finalFrame = originFrame
        
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.0,
            animations: {
                searchController.view.alpha = 0.0
                searchController.cancelButton.alpha = 0.0
                searchIconView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
            },
            completion: { _ in
                feedController.searchImageView.alpha = 1.0
                searchIconView.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        )
    }
}
