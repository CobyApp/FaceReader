//
//  PreviewLayerHost.swift
//  FaceReader
//

import AVFoundation
import SwiftUI
import UIKit

/// Hosts `AVCaptureVideoPreviewLayer` and keeps `frame` in sync with layout (avoids zero-sized preview).
private final class PreviewContainerView: UIView {
    var videoPreviewLayer: AVCaptureVideoPreviewLayer? {
        didSet {
            setNeedsLayout()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer?.frame = bounds
    }
}

public struct PreviewLayerHost: UIViewRepresentable {
    public let previewLayer: AVCaptureVideoPreviewLayer

    public init(previewLayer: AVCaptureVideoPreviewLayer) {
        self.previewLayer = previewLayer
    }

    public func makeUIView(context: Context) -> UIView {
        let view = PreviewContainerView()
        previewLayer.removeFromSuperlayer()
        view.layer.insertSublayer(previewLayer, at: 0)
        view.videoPreviewLayer = previewLayer
        return view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        (uiView as? PreviewContainerView)?.videoPreviewLayer = previewLayer
        previewLayer.frame = uiView.bounds
    }
}
