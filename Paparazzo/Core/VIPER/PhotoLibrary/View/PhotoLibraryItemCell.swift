
import ImageSource
import UIKit

final class PhotoLibraryItemCell: PhotoCollectionViewCell, Customizable {
    
    private let cloudIconView = UIImageView()
    private var getSelectionIndex: (() -> Int?)?
    
    private let selectionIndexBadge: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.black.withAlphaComponent(0.633195)
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 13)
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.isHidden = true
        return label
    }()
    
    // MARK: - UICollectionViewCell
    
    override var backgroundColor: UIColor? {
        get { return backgroundView?.backgroundColor }
        set { backgroundView?.backgroundColor = newValue }
    }
    
    override var isSelected: Bool {
        didSet {
            imageView.transform = .identity
            
            guard let getSelectionIndex = getSelectionIndex else { return }
            
            layer.borderWidth = 0
            
            if isSelected {
                imageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }
            
            DispatchQueue.main.async {
                if self.isSelected, let selectionIndex = getSelectionIndex() {
                    self.selectionIndexBadge.isHidden = false
                    self.selectionIndexBadge.text = String(selectionIndex)
                } else {
                    self.selectionIndexBadge.isHidden = true
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        getSelectionIndex = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let backgroundView = UIView()
        let onePixel = 1.0 / UIScreen.main.nativeScale
        
//        self.backgroundView = backgroundView
        
        selectedBorderThickness = 5
        
        imageView.isAccessibilityElement = true
        imageViewInsets = UIEdgeInsets(top: onePixel, left: onePixel, bottom: onePixel, right: onePixel)
        
        setUpRoundedCorners(for: self)
        setUpRoundedCorners(for: backgroundView)
        setUpRoundedCorners(for: imageView)
        
        contentView.insertSubview(cloudIconView, at: 0)
        contentView.addSubview(selectionIndexBadge)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let onePixel = CGFloat(1) / UIScreen.main.nativeScale
        let backgroundInsets = UIEdgeInsets(top: onePixel, left: onePixel, bottom: onePixel, right: onePixel)
        
        backgroundView?.frame = imageView.frame.inset(by: backgroundInsets)
        
        cloudIconView.sizeToFit()
        cloudIconView.right = contentView.bounds.right
        cloudIconView.bottom = contentView.bounds.bottom
        
        selectionIndexBadge.layout(
            left: bounds.left + 10,
            top: bounds.top + 10,
            width: 20,
            height: 20
        )
    }
    
    override func didRequestImage(requestId imageRequestId: ImageRequestId) {
        self.imageRequestId = imageRequestId
    }
    
    override func imageRequestResultReceived(_ result: ImageRequestResult<UIImage>) {
        if result.requestId == self.imageRequestId {
            onImageSetFromSource?()
        }
    }
    
    // MARK: - PhotoLibraryItemCell
    
    func setCloudIcon(_ icon: UIImage?) {
        cloudIconView.image = icon
        setNeedsLayout()
    }
    
    func setAccessibilityId(index: Int) {
        accessibilityIdentifier = AccessibilityId.mediaItemThumbnailCell.rawValue + "-\(index)"
    }
    
    // MARK: - Customizable
    
    var onImageSetFromSource: (() -> ())?
    
    func customizeWithItem(_ item: PhotoLibraryItemCellData) {
        imageSource = item.image
        getSelectionIndex = item.getSelectionIndex
        isSelected = item.selected
    }
    
    // MARK: - Private
    
    private var imageRequestId: ImageRequestId?
    
    private func setUpRoundedCorners(for view: UIView) {
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.nativeScale
    }
}
