import Foundation
import UIKit

class ProjectAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    /// The image which will be replaced by the close button
    var moveImageNameUp: String = ""
    
    /// The project's image to animate into view
    var projectImageView: UIImageView?
    
    /// Called when view controller animation has dismissed
    var dismissCompletion: (() -> Void)?
    
    private let duration: TimeInterval = 0.33

    // Used when dismissing
    private var currentImageViewBeginFrame: CGRect = .zero
    private var endCurrentImageFrame: CGRect = .zero
    private var closeImageViewBeginFrame: CGRect = .zero
    private var endCloseImageFrame: CGRect = .zero
    private var _projectImageView: UIImageView?
    private var projectImageBeginFrame: CGRect = .zero
    private var endProjectImageViewFrame: CGRect = .zero
    
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
        guard let toView = transitionContext.view(forKey: .to),
              let toController = transitionContext.viewController(forKey: .to) as? ProjectDetailsViewController else {
            return print("Failed to get `ProjectDetailsViewController` from `transitionContext`")
        }
        
        guard let toCloseView = toController.closeImageView,
              let toProjectImageView = toController.imageView else {
            return print("Failed to get `ProjectDetailsViewController` views")
        }
        
        let closeViewXPos: CGFloat = toCloseView.frame.origin.x - 30
        // view: 48 (height of `CenteredImageView`) - image: 30 = 9.0
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
        endCurrentImageFrame = CGRect(
            x: closeViewXPos,
            y: -40.0,
            width: 30.0,
            height: 30.0
        )
        
        // MARK: Move close image up into view
        
        let imageView = UIImage(named: "close")?.sd_tintedImage(with: UIColor.bk.white)
        let closeImageView = UIImageView(image: imageView)
        let navigationBarFrame = toController.navigationBarView.frame
        closeImageView.frame = CGRect(
            x: closeViewXPos,
            y: navigationBarFrame.origin.y + navigationBarFrame.size.height,
            width: 30.0,
            height: 30.0
        )
        endCloseImageFrame = toCloseView.frame
        endCloseImageFrame.origin = CGPoint(x: closeViewXPos, y: closeViewYPos)
        endCloseImageFrame.size = closeImageView.frame.size
         
        // MARK: Move project image into view
        
        // FIXME: We may have to set the project image as the imge displayed in the details page to be consistent.
        
        if let view = projectImageView,
           let projectImage = view.image,
           let frame = view.superview?.convert(view.frame, to: nil),
           let cgImage = projectImage.cgImage,
           let copyCgImage = cgImage.copy() {
            let copyImage = UIImage(cgImage: copyCgImage)
            let imageView = UIImageView(image: copyImage)
            imageView.frame = frame
            
            let endFrame = toProjectImageView.superview?.convert(toProjectImageView.frame, to: nil) ?? .zero
            endProjectImageViewFrame = CGRect(x: endFrame.origin.x, y: endFrame.origin.y + UIApplication.shared.statusBarFrame.size.height, width: view.frame.size.width, height: toProjectImageView.frame.size.height)
            
            projectImageBeginFrame = frame
            _projectImageView = imageView
        }
        
        // MARK: Initialize to view state
        
        // Hide close image
        toController.closeImageView.alpha = 0.0
        
        // Add views to animate into respective subviews
        toController.navigationBarView.addSubview(currentImageView)
        toController.navigationBarView.bringSubviewToFront(currentImageView)
        toController.navigationBarView.addSubview(closeImageView)
        toController.navigationBarView.bringSubviewToFront(closeImageView)
                
        containerView.addSubview(toView)
        containerView.bringSubviewToFront(toView)
        
        if let view = _projectImageView {
            toController.imageView.alpha = 0.0
            containerView.addSubview(view)
            containerView.bringSubviewToFront(view)
        }

        currentImageViewBeginFrame = currentImageView.frame
        closeImageViewBeginFrame = closeImageView.frame
        
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.0,
            animations: { [weak self] in
                guard let sself = self else {
                    return
                }
                currentImageView.frame = sself.endCurrentImageFrame
                closeImageView.frame = sself.endCloseImageFrame
                sself._projectImageView?.frame = sself.endProjectImageViewFrame
            },
            completion: { [weak self] _ in
                toController.closeImageView.alpha = 1.0
                toController.imageView.alpha = 1.0
                closeImageView.removeFromSuperview()
                currentImageView.removeFromSuperview()
                self?._projectImageView?.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        )
    }
    
    private func animateDismiss(_ transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let fromController = transitionContext.viewController(forKey: .from) as? ProjectDetailsViewController else {
            return log.w("Failed to get controllers to transition to/from")
        }
        
        let muImage = UIImage(named: moveImageNameUp)?.sd_tintedImage(with: UIColor.bk.white)
        let currentImageView = UIImageView(image: muImage)
        currentImageView.frame = endCurrentImageFrame
        
        let imageView = UIImage(named: "close")?.sd_tintedImage(with: UIColor.bk.white)
        let closeImageView = UIImageView(image: imageView)
        closeImageView.frame = endCloseImageFrame
        
        if let view = projectImageView,
           let projectImage = view.image,
           let cgImage = projectImage.cgImage,
           let copyCgImage = cgImage.copy() {
            let copyImage = UIImage(cgImage: copyCgImage)
            let imageView = UIImageView(image: copyImage)
            imageView.frame = endProjectImageViewFrame
            _projectImageView = imageView
            containerView.addSubview(imageView)
            containerView.bringSubviewToFront(imageView)
        }

        fromController.imageView.alpha = 0.0
        fromController.closeImageView.alpha = 0.0
        
        // Add views to animate into respective subviews
        fromController.navigationBarView.addSubview(currentImageView)
        fromController.navigationBarView.bringSubviewToFront(currentImageView)
        fromController.navigationBarView.addSubview(closeImageView)
        fromController.navigationBarView.bringSubviewToFront(closeImageView)

        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.0,
            animations: { [weak self] in
                guard let sself = self else {
                    return
                }
                fromController.view.alpha = 0.0
                currentImageView.frame = sself.currentImageViewBeginFrame
                closeImageView.frame = sself.closeImageViewBeginFrame
                sself._projectImageView?.frame = sself.projectImageBeginFrame
            },
            completion: { [weak self] _ in
                closeImageView.removeFromSuperview()
                currentImageView.removeFromSuperview()
                self?._projectImageView?.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        )
    }
}
