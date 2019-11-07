import Foundation
import UIKit

class ProjectAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    // TODO: Project Image
    // TODO: Project name
    var moveImageNameUp: String = ""
    var projectImageView: UIImageView?
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
              let toView = transitionContext.view(forKey: .to),
              let toController = transitionContext.viewController(forKey: .to) as? ProjectDetailsViewController else {
            return print("Failed to get `ProjectDetailsViewController` from `transitionContext`")
        }
        
        // TODO: Animate the search icon out of view. Then back into view.
        guard let toCloseView = toController.closeImageView,
              let toProjectImageView = toController.imageView else {
            return print("Failed to get `ProjectDetailsViewController` views")
        }
        
        let closeViewXPos: CGFloat = toCloseView.frame.origin.x - 30
        // view: 48 - image: 30 = 9.0
        let closeViewYPos: CGFloat = 9.0
        
        // MARK: Move existing image out of view
        
        let muImage = UIImage(named: moveImageNameUp)?.sd_tintedImage(with: UIColor.bk.white)
        let currentImageView = UIImageView(image: muImage)
        currentImageView.frame = CGRect(
            x: closeViewXPos,
            y: closeViewYPos,
            width: 30.0,
            height: 30.0
        )
        let endCurrentImageFrame = CGRect(
            x: closeViewXPos,
            y: -40.0,
            width: 30.0,
            height: 30.0
        )
        
        // MARK: Move close image up into view
        
        let imageView = UIImage(named: "close")?.sd_tintedImage(with: UIColor.bk.white)
        let closeIconView = UIImageView(image: imageView)
        let navigationBarFrame = toController.navigationBarView.frame
        closeIconView.frame = CGRect(
            x: closeViewXPos,
            y: navigationBarFrame.origin.y + navigationBarFrame.size.height,
            width: 30.0,
            height: 30.0
        )
        var endCloseImageFrame = toCloseView.frame
        endCloseImageFrame.origin = CGPoint(x: closeViewXPos, y: closeViewYPos)
        endCloseImageFrame.size = closeIconView.frame.size
         
        // MARK: Project image
        
        var projectImageView: UIImageView?
        var endProjectImageViewFrame: CGRect = .zero
        if let view = self.projectImageView,
           let projectImage = view.image,
           let frame = view.superview?.convert(view.frame, to: nil),
           let cgImage = projectImage.cgImage,
           let copyCgImage = cgImage.copy() {
            let copyImage = UIImage(cgImage: copyCgImage)
            let imageView = UIImageView(image: copyImage)
            imageView.frame = frame
            
            let endFrame = toProjectImageView.superview?.convert(toProjectImageView.frame, to: nil) ?? .zero
            endProjectImageViewFrame = CGRect(x: endFrame.origin.x, y: endFrame.origin.y + UIApplication.shared.statusBarFrame.size.height, width: view.frame.size.width, height: toProjectImageView.frame.size.height)
            
            projectImageView = imageView
        }
        
        // MARK: Initialize to view state
        
        // Hide close image
        toController.closeImageView.alpha = 0.0
        
        // Add views to animate into respective subviews
        toController.navigationBarView.addSubview(currentImageView)
        toController.navigationBarView.bringSubviewToFront(currentImageView)
        toController.navigationBarView.addSubview(closeIconView)
        toController.navigationBarView.bringSubviewToFront(closeIconView)
                
        containerView.addSubview(toView)
        containerView.bringSubviewToFront(toView)
        
        if let view = projectImageView {
            toController.imageView.alpha = 0.0
            containerView.addSubview(view)
            containerView.bringSubviewToFront(view)
        }

        self.finalFrame = toCloseView.frame
        
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.0,
            animations: {
                currentImageView.frame = endCurrentImageFrame
                closeIconView.frame = endCloseImageFrame
                projectImageView?.frame = endProjectImageViewFrame
            },
            completion: { _ in
                toController.closeImageView.alpha = 1.0
                toController.imageView.alpha = 1.0
                closeIconView.removeFromSuperview()
                currentImageView.removeFromSuperview()
                projectImageView?.removeFromSuperview()
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

//        let finalFrame = originFrame
//        
//        UIView.animate(
//            withDuration: duration,
//            delay: 0.0,
//            usingSpringWithDamping: 0.8,
//            initialSpringVelocity: 0.0,
//            animations: {
//                searchController.cancelButton.alpha = 0.0
//                searchIconView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
//            },
//            completion: { _ in
//                feedController.searchImageView.alpha = 1.0
//                searchIconView.removeFromSuperview()
//                transitionContext.completeTransition(true)
//            }
//        )
    }
}
