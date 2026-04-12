//
//  PreviewLayerHost.swift
//  FaceReader
//

import AVFoundation
import SwiftUI

struct PreviewLayerHost: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        previewLayer.removeFromSuperlayer()
        view.layer.insertSublayer(previewLayer, at: 0)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        previewLayer.frame = uiView.bounds
    }
}
