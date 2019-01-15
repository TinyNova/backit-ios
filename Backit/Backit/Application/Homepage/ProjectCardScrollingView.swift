/**
 Provides horizontal scrolling list of project card images.
 
 Useful links:
 https://samwize.com/2015/11/30/understanding-uicollection-flow-layout/
 */

import UIKit

private enum Constant {
    static var CellIdentifier = "Cell"
}

class ProjectCardScrollView: UICollectionView {

    private var indexOfCellBeforeDragging = 0
    
    private var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    var assets: [ProjectAsset] = [] {
        didSet {
            reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    private func commonInit() {
        register(UINib(nibName: "ProjectCardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: Constant.CellIdentifier)
        
        collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionViewFlowLayout.minimumLineSpacing = 0
        let screenWidth = UIScreen.main.bounds.size.width
        collectionViewFlowLayout.itemSize = CGSize(width: screenWidth, height: 200.0)
        collectionViewFlowLayout.scrollDirection = .horizontal
        collectionViewLayout = collectionViewFlowLayout
        
        dataSource = self
    }
    
    private func indexOfMajorCell() -> Int {
        let itemWidth = collectionViewFlowLayout.itemSize.width
        let proportionalOffset = collectionViewLayout.collectionView!.contentOffset.x / itemWidth
        let index = Int(round(proportionalOffset))
        let numItems = numberOfItems(inSection: 0)
        let safeIndex = max(0, min(numItems - 1, index))
        return safeIndex
    }
}

extension ProjectCardScrollView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.CellIdentifier, for: indexPath) as? ProjectCardCollectionViewCell else {
            fatalError("Failed to deque cell")
        }
        
        cell.configure(asset: assets[indexPath.row])
        return cell
    }
}

extension ProjectCardScrollView: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        indexOfCellBeforeDragging = indexOfMajorCell()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Stop scrollView sliding
        targetContentOffset.pointee = scrollView.contentOffset
        
        // Calculate where scrollView should snap to
        let indexOfMajorCell = self.indexOfMajorCell()
        
        let dataSourceCount = collectionView(self, numberOfItemsInSection: 0)
        let swipeVelocityThreshold: CGFloat = 0.5
        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < dataSourceCount && velocity.x > swipeVelocityThreshold
        let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)
        
        if didUseSwipeToSkipCell {
            let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
            let toValue = collectionViewFlowLayout.itemSize.width * CGFloat(snapToIndex)
            
            // Damping equal 1 => no oscillations => decay animation
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity.x, options: .allowUserInteraction, animations: {
                scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                scrollView.layoutIfNeeded()
            }, completion: nil)
        } else {
            // This is a much better way to scroll to a cell
            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
            collectionViewLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
}

class ProjectCardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func configure(asset: ProjectAsset) {
        let url: URL
        switch asset {
        case .image(let imageURL):
            url = imageURL
        case .video(let previewURL, _):
            url = previewURL
        }
        
        let screenWidth = UIScreen.main.bounds.size.width
        imageView.sd_setImage(with: url, placeholderImage: nil, options: [], progress: nil) { [weak self] (image, error, cacheType, imageURL) in
            self?.imageView.image = self?.fittedImage(from: image, to: screenWidth)
        }
    }
    
    private func fittedImage(from image: UIImage?, to width: CGFloat) -> UIImage? {
        guard let image = image else {
            return nil
        }
        
        let oldWidth = image.size.width
        let scaleFactor = width / oldWidth
        
        let newHeight = image.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        let size = CGSize(width: newWidth, height: newHeight)
        // NOTE: Make sure this is using the more efficient version of drawing images.
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        image.draw(in: CGRect(x:0, y:0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
