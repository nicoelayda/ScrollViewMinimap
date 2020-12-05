//
//  Copyright © 2020 Dominic Elayda.
//  Licensed under The MIT License.
//

import UIKit

open class ScrollViewMinimap: UIControl {
    
    public weak var scrollView: UIScrollView? {
        didSet {
            imageView.image = scrollView?.asImage()
        }
    }
    
    public var scrollViewCentersContent = false
    
    // MARK: - Image View
    
    private let imageView = UIImageView()
    
    // MARK: - Highlight View
    
    private let highlightView = UIView()
    
    private lazy var highlightViewTopConstraint: NSLayoutConstraint = {
        highlightView.topAnchor.constraint(equalTo: topAnchor)
    }()
    
    private lazy var highlightViewLeftConstraint: NSLayoutConstraint = {
        highlightView.leftAnchor.constraint(equalTo: leftAnchor)
    }()
    
    private lazy var highlightViewWidthConstraint: NSLayoutConstraint = {
        highlightView.widthAnchor.constraint(equalToConstant: frame.width)
    }()
    
    private lazy var highlightViewHeightConstraint: NSLayoutConstraint = {
        highlightView.heightAnchor.constraint(equalToConstant: frame.height)
    }()
    
    private var highlightViewSize: CGSize {
        CGSize(width: min(frame.width, frame.width / zoomScale * minimumZoomScale),
               height: min(frame.height, frame.height / zoomScale * minimumZoomScale))
    }
    
    private var scrollableArea: CGSize {
        CGSize(width: frame.width - highlightViewSize.width,
               height: frame.height - highlightViewSize.height)
    }
    
    // MARK: - UIView
    
    public override var bounds: CGRect {
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let scrollView = scrollView else { return }
        let lastZoomScale = scrollView.zoomScale
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        imageView.image = scrollView.asImage()
        scrollView.setZoomScale(lastZoomScale, animated: false)
    }
    
    public override func updateConstraints() {
        var leftOffset = (contentInset.left + contentOffset.x) / (zoomScale * scrollViewWidthScale) * minimumZoomScale
        var topOffset = (contentInset.top + contentOffset.y) / (zoomScale * scrollViewHeightScale) * minimumZoomScale
        
        if scrollViewCentersContent, let scrollView = scrollView {
            let maxXCenteringOffset = (scrollView.frame.width - (scrollView.trueContentSize.width * minimumZoomScale)) / scrollViewWidthScale
            leftOffset += min(scrollableArea.width, maxXCenteringOffset) / 2
            
            let maxYCenteringOffset = (scrollView.frame.height - (scrollView.trueContentSize.height * minimumZoomScale)) / scrollViewHeightScale
            topOffset += min(scrollableArea.height, maxYCenteringOffset) / 2
        }
        
        highlightViewLeftConstraint.constant = min(max(0, leftOffset), scrollableArea.width)
        highlightViewTopConstraint.constant = min(max(0, topOffset), scrollableArea.height)
        highlightViewWidthConstraint.constant = highlightViewSize.width
        highlightViewHeightConstraint.constant = highlightViewSize.height

        super.updateConstraints()
    }
    
    // MARK: - Initializers
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setupSubviews()
    }
    
    // MARK: - Setup
    
    private func setupSubviews() {
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        addSubview(highlightView)
        highlightView.layer.borderColor = UIColor.red.cgColor
        highlightView.layer.borderWidth = 2
        
        highlightView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            highlightViewTopConstraint,
            highlightViewLeftConstraint,
            highlightViewWidthConstraint,
            highlightViewHeightConstraint,
        ])
    }
    
}

private extension ScrollViewMinimap {
    
    var contentInset: UIEdgeInsets {
        guard let scrollView = scrollView else { return UIEdgeInsets.zero }
        return scrollView.contentInset
    }
    
    var contentOffset: CGPoint {
        guard let scrollView = scrollView else { return CGPoint.zero }
        return scrollView.contentOffset
    }
    
    var zoomScale: CGFloat {
        guard let scrollView = scrollView else { return 1 }
        return scrollView.zoomScale
    }
    
    var minimumZoomScale: CGFloat {
        guard let scrollView = scrollView else { return 1 }
        return scrollView.minimumZoomScale
    }
    
    // Minimap width scale relative to managed UIScrollView's width
    var scrollViewWidthScale: CGFloat {
        guard let scrollView = scrollView else { return 1 }
        return scrollView.frame.width / frame.width
    }
    
    // Minimap height scale relative to managed UIScrollView's height
    var scrollViewHeightScale: CGFloat {
        guard let scrollView = scrollView else { return 1 }
        return scrollView.frame.height / frame.height
    }
    
}

private extension UIView {
    
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { context in
            layer.render(in: context.cgContext)
        }
    }
}

private extension UIScrollView {
    
    var trueContentSize: CGSize {
        CGSize(width: contentSize.width / zoomScale,
               height: contentSize.height / zoomScale)
    }
    
}
