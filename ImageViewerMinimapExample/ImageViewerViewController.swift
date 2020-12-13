//
//  Copyright © 2020 Dominic Elayda.
//  Licensed under The MIT License.
//

import UIKit
import ScrollViewMinimap

class ImageViewerViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var minimap: ScrollViewMinimap!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScrollView()
        setupImageView()
        setupMinimap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        centerContentView(in: scrollView)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else { return }
            self.centerContentView(in: self.scrollView)
            self.minimap.addDropShadow()
        }, completion: nil)

    }
    
    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 8.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
    }
    
    private func setupImageView() {
        guard let image = UIImage(named: "Building") else { return }
        let aspectRatio = image.size.width / image.size.height
        imageView.image = image
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: aspectRatio).isActive = true
    }

    private func setupMinimap() {
        minimap.scrollView = scrollView
        minimap.showsHighlightOnMinimumZoomScale = false
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.minimap.addDropShadow()
            self.minimap.setNeedsDisplay()
        }
    }
    
    private func centerContentView(in scrollView: UIScrollView) {
        // Centers the content view if it is smaller than the scroll view frame.
        let leftOffset = max((scrollView.bounds.width - scrollView.contentSize.width) / 2, 0)
        let topOffset = max((scrollView.bounds.height - scrollView.contentSize.height) / 2, 0)
        scrollView.contentInset = UIEdgeInsets(top: topOffset, left: leftOffset, bottom: 0, right: 0)
    }
}

// MARK: - UIScrollViewDelegate

extension ImageViewerViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        minimap.update(animated: true)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.centerContentView(in: self.scrollView)
        minimap.update(animated: true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
}

// MARK: - UIView Extension - Drop Shadows

private extension UIView {
    
    func addDropShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: -3)
        layer.shadowRadius = 8
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
}

// MARK: - Live Preview

import SwiftUI

@available(iOS 13, *)
struct ImageViewerViewControllerRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> ImageViewerViewController {
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ImageViewerViewController")
    }
    
    func updateUIViewController(_ uiViewController: ImageViewerViewController, context: Context) { }
    
}

@available(iOS 13, *)
struct ViewController_Preview: PreviewProvider {

    static var devices = ["iPhone 12 Pro"]

    static var previews: some View {
        ForEach(devices, id: \.self) { deviceName in
            ImageViewerViewControllerRepresentable()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
    }
}
