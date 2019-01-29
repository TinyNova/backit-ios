/**
 * Provides horizontal scrolling list of project card images.
 *
 * Useful links:
 * https://samwize.com/2015/11/30/understanding-uicollection-flow-layout/
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import AVKit
import UIKit
import SDWebImage

private enum Constant {
    static var CellIdentifier = "Cell"
    static var AnimatedCellIdentifier = "AnimatedCell"
}

protocol ProjectCardScrollViewDelegate: class {
    func didSelectProject(_ project: ProjectAsset)
    func didScrollToProject(_ project: ProjectAsset, at index: Int)
}

class ProjectCardScrollView: UICollectionView {

    public weak var projectCardDelegate: ProjectCardScrollViewDelegate?
    
    private var currentCellIndex = 0
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
        register(UINib(nibName: "ProjectCardCollectionViewAnimatedCell", bundle: nil), forCellWithReuseIdentifier: Constant.AnimatedCellIdentifier)

        collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionViewFlowLayout.minimumLineSpacing = 0
        let screenWidth = UIScreen.main.bounds.size.width
        collectionViewFlowLayout.itemSize = CGSize(width: screenWidth, height: 200.0)
        collectionViewFlowLayout.scrollDirection = .horizontal
        collectionViewLayout = collectionViewFlowLayout
        
        delegate = self
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
        let asset = assets[indexPath.row]
        let cellIdentifier: String
        let url: URL
        switch asset {
        case .image(let imageURL):
            cellIdentifier = Constant.CellIdentifier
            url = imageURL
        case .video(let previewURL, _):
            cellIdentifier = Constant.AnimatedCellIdentifier
            url = previewURL
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        
        if let cell = cell as? ProjectCardCell {
            cell.configure(url: url)
        }
        
        return cell
    }
}

extension ProjectCardScrollView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        projectCardDelegate?.didSelectProject(assets[indexPath.row])
    }
}

extension ProjectCardScrollView: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        indexOfCellBeforeDragging = indexOfMajorCell()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee = scrollView.contentOffset
        
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
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity.x, options: .allowUserInteraction, animations: { [weak self] in
                scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                scrollView.layoutIfNeeded()
                
                self?.scrolledToIndex(snapToIndex)
            }, completion: nil)
        }
        else {
            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
            collectionViewLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            scrolledToIndex(indexOfMajorCell)
        }
    }
    
    private func scrolledToIndex(_ index: Int) {
        guard currentCellIndex != index else {
            return
        }
        currentCellIndex = index
        projectCardDelegate?.didScrollToProject(assets[index], at: index)
    }
}

// MARK: - ProjectCardCell

private protocol ProjectCardCell {
    func configure(url: URL)
}

class ProjectCardCollectionViewCell: UICollectionViewCell, ProjectCardCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func configure(url: URL) {
        // FIXME: Move this into a dependency. First version should return only the image.
        let manager = SDWebImageManager.shared()
        manager.loadImage(with: url, options: [], progress: nil) { [weak self] (image, data, error, cacheType, finished, imageURL) in
            guard let strongSelf = self, let image = image else {
                self?.imageView.image = nil
                return
            }
            // FIXME: Move this into a dependency.
            let screenWidth = UIScreen.main.bounds.size.width
            strongSelf.imageView.image = image.fittedImage(to: screenWidth)
        }
    }
}

class ProjectCardCollectionViewAnimatedCell: UICollectionViewCell, ProjectCardCell {
    
    @IBOutlet weak var playButtonImageView: UIImageView! {
        didSet {
            let image = UIImage(named: "carousel-play")?.withRenderingMode(.alwaysTemplate)
            playButtonImageView.image = image
            theme.apply(.playButtonOverlay, toImage: playButtonImageView)
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    private var theme: UIThemeApplier<AppTheme> = AppTheme.default

    func inject(theme: UIThemeApplier<AppTheme>) {
        self.theme = theme
    }

    var player: AVPlayer?
    
    func configure(url: URL) {
        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        player.isMuted = true
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = bounds
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        
        player.seek(to: .zero)
        player.play()
        self.player = player
        
        loopVideo(player)
        
        self.bringSubviewToFront(self.playButtonImageView)
    }
    
    private func loopVideo(_ videoPlayer: AVPlayer) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem, queue: OperationQueue.main) { notification in
            guard let playerItem = notification.object as? AVPlayerItem, videoPlayer.currentItem == playerItem else {
                return
            }
            videoPlayer.seek(to: .zero)
            videoPlayer.play()
        }
    }
}
