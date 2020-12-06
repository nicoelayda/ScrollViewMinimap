//
//  Copyright © 2020 Dominic Elayda.
//  Licensed under The MIT License.
//

import UIKit

@IBDesignable
open class ScrollViewMinimap: UIControl {
    
    @IBInspectable open var highlightAlpha: CGFloat = 0.4
    @IBInspectable open var highlightBorderColor: UIColor = .gray
    @IBInspectable open var highlightBorderWidth: CGFloat = 1
    @IBInspectable open var highlightColor: UIColor = .white
    
    public weak var scrollView: UIScrollView? {
        didSet {
            imageView.image = scrollView?.contentViewThumbnailImage()
            setNeedsUpdateConstraints()
        }
    }
    
    public func update(animated: Bool) {
        setNeedsUpdateConstraints()
        updateHighlightViewVisibility(animated: animated)
    }
    
    // MARK: - Image View
    
    private let imageView = UIImageView()
    
    private lazy var imageViewAspectRatioConstraint: NSLayoutConstraint = {
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
    }()
    
    // MARK: - Highlight View
    
    public var showsHighlightOnMinimumZoomScale = true
    
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
        guard let scrollView = scrollView else { return .zero }
        let translatedScrollViewScaleFactor = scrollViewScaleFactor(translatedForMinimumZoomScale: true)
        return CGSize(width: min(frame.width, scrollView.frame.width / translatedScrollViewScaleFactor),
                      height: min(frame.height, scrollView.frame.height / translatedScrollViewScaleFactor))
    }
    
    private var scrollableArea: CGSize {
        CGSize(width: frame.width - highlightViewSize.width,
               height: frame.height - highlightViewSize.height)
    }
    
    private func updateHighlightViewVisibility(animated: Bool) {
        var newAlpha: CGFloat = highlightAlpha
        if !showsHighlightOnMinimumZoomScale, highlightViewSize.equalTo(frame.size) {
            newAlpha = 0
        }
        
        if !Float(newAlpha).isEqual(to: Float(highlightView.alpha)) {
            let changeAlpha: () -> () = { [weak self] in
                self?.highlightView.alpha = newAlpha
            }
            if animated {
                UIView.animate(withDuration: 0.2, animations: changeAlpha)
            } else {
                changeAlpha()
            }
        }
    }
    
    // MARK: - UIView
    
    public override var bounds: CGRect {
        didSet {
            setNeedsDisplay()
            setNeedsUpdateConstraints()
        }
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let scrollView = scrollView else { return }
        imageView.image = scrollView.contentViewThumbnailImage()
    }
    
    public override func updateConstraints() {
        guard let scrollView = scrollView else {
            super.updateConstraints()
            return
        }
        
        let translatedScrollViewScaleFactor = scrollViewScaleFactor(translatedForMinimumZoomScale: true)
        let leftOffset = (scrollView.contentInset.left + scrollView.contentOffset.x) / translatedScrollViewScaleFactor
        let topOffset = (scrollView.contentInset.top + scrollView.contentOffset.y) / translatedScrollViewScaleFactor
        
        if imageViewAspectRatioConstraint.multiplier != scrollView.contentSizeAspectRatio {
            imageView.removeConstraint(imageViewAspectRatioConstraint)
            imageViewAspectRatioConstraint = imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: scrollView.contentSizeAspectRatio)
            imageViewAspectRatioConstraint.isActive = true
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
        setupGestureRecognizers()
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
            imageViewAspectRatioConstraint,
        ])
        
        addSubview(highlightView)
        highlightView.alpha = highlightAlpha
        highlightView.backgroundColor = highlightColor
        highlightView.layer.borderColor = highlightBorderColor.cgColor
        highlightView.layer.borderWidth = highlightBorderWidth
        
        highlightView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            highlightViewTopConstraint,
            highlightViewLeftConstraint,
            highlightViewWidthConstraint,
            highlightViewHeightConstraint,
        ])
    }
    
    private func setupGestureRecognizers() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        highlightView.addGestureRecognizer(panGestureRecognizer)
    }
 
    // MARK: - Gesture recognizers

    private var lastKnownContentOffset: CGPoint = CGPoint.zero

    @objc
    private func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let scrollView = scrollView else { return }
        if gestureRecognizer.state == .began {
            lastKnownContentOffset = scrollView.contentOffset
        }
        
        let translationPoint = gestureRecognizer.translation(in: self)
        let translatedScrollViewScaleFactor = scrollViewScaleFactor(translatedForMinimumZoomScale: true)
        let scaledTranslationPoint = CGPoint(x: translationPoint.x * translatedScrollViewScaleFactor,
                                             y: translationPoint.y * translatedScrollViewScaleFactor)
        
        let maxXContentOffset = max(scrollView.contentInset.left + scrollView.contentSize.width - (highlightViewSize.width * translatedScrollViewScaleFactor), 0)
        let maxYContentOffset = max(scrollView.contentInset.top + scrollView.contentSize.height - (highlightViewSize.height * translatedScrollViewScaleFactor), 0)
        scrollView.contentOffset = CGPoint(x: min(max(-scrollView.contentInset.left, lastKnownContentOffset.x + scaledTranslationPoint.x), maxXContentOffset),
                                           y: min(max(-scrollView.contentInset.top, lastKnownContentOffset.y + scaledTranslationPoint.y), maxYContentOffset))
    }
    
}

private extension ScrollViewMinimap {
    
    func zoomScale(relativeToMinimumZoomScale: Bool = false) -> CGFloat {
        guard let scrollView = scrollView else { return 1 }
        if relativeToMinimumZoomScale {
            return scrollView.zoomScale / scrollView.minimumZoomScale
        }
        return scrollView.zoomScale
    }
    
    func scrollViewScaleFactor(translatedForMinimumZoomScale: Bool = false) -> CGFloat {
        guard let scrollView = scrollView else { return 1 }
        let scrollViewScaleFactor = min(scrollView.frame.width / frame.width,
                                        scrollView.frame.height / frame.height)
        if translatedForMinimumZoomScale {
            return scrollViewScaleFactor * zoomScale(relativeToMinimumZoomScale: true)
        }
        return scrollViewScaleFactor
    }
    
}

private extension UIScrollView {
    
    var contentSizeAspectRatio: CGFloat {
        guard contentSize.height != 0 else { return 1 }
        return contentSize.width / contentSize.height
    }
    
    func contentViewThumbnailImage() -> UIImage? {
        let oldZoomScale = zoomScale
        let oldOrigin = bounds.origin
        
        setZoomScale(minimumZoomScale, animated: false)
        bounds.origin = .zero
        
        let boundsAspectRatio = bounds.width / bounds.height
        let contentAspectRatio = contentSizeAspectRatio
        
        var contentSize = bounds.size
        if (boundsAspectRatio < contentAspectRatio) {
            contentSize.height = contentSize.height / contentAspectRatio * boundsAspectRatio
        } else {
            contentSize.width = contentSize.width / boundsAspectRatio * contentAspectRatio
        }
        
        let renderer = UIGraphicsImageRenderer(bounds: CGRect(origin: .zero, size: contentSize))
        let image = renderer.image { context in
            layer.render(in: context.cgContext)
        }
        
        setZoomScale(oldZoomScale, animated: false)
        bounds.origin = oldOrigin
        
        return image
    }
    
}

// MARK: - Interface builder

extension ScrollViewMinimap {
    
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        setupSubviews()
        
        highlightViewLeftConstraint.constant = 16
        highlightViewTopConstraint.constant = 16
        highlightViewWidthConstraint.constant = frame.width * 0.5
        highlightViewHeightConstraint.constant = frame.height * 0.5
        
        let bundle = Bundle(for: Self.self)
        imageView.image = UIImage(named: "Building", in: bundle, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
    
}
