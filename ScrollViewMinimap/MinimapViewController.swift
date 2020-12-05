//
//  Copyright © 2020 Dominic Elayda.
//  Licensed under The MIT License.
//

import UIKit

class MinimapViewController: UIViewController {

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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.centerContentView(in: self.scrollView)
        }
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
        minimap.scrollViewCentersContent = true
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
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

extension MinimapViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        minimap.setNeedsUpdateConstraints()
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.centerContentView(in: self.scrollView)
        minimap.setNeedsUpdateConstraints()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
}

// MARK: - Live Preview

import SwiftUI

@available(iOS 13, *)
struct MinimapViewControllerRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> MinimapViewController {
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MinimapViewController")
    }
    
    func updateUIViewController(_ uiViewController: MinimapViewController, context: Context) { }
    
}

@available(iOS 13, *)
struct ViewController_Preview: PreviewProvider {

    static var devices = ["iPhone 12 Pro"]

    static var previews: some View {
        ForEach(devices, id: \.self) { deviceName in
            MinimapViewControllerRepresentable()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
    }
}
