//
//  FaceCaptureView.swift
//  FaceReader
//

import FaceReaderCore
import FaceReaderLocalization
import FaceReaderUI
import SwiftUI
import UIKit

public struct FaceCaptureView: View {
    let box: SessionBox
    var onCommitted: (Data?) -> Void

    @StateObject private var engine: FaceCaptureEngine
    @State private var isProcessing = false
    @State private var showNeedFaceAlert = false

    public init(
        box: SessionBox,
        onCommitted: @escaping (Data?) -> Void
    ) {
        self.box = box
        self.onCommitted = onCommitted
        _engine = StateObject(wrappedValue: FaceCaptureEngine(measureSession: box.session))
    }

    public var body: some View {
        ZStack {
            PreviewLayerHost(previewLayer: engine.previewLayer)
                .ignoresSafeArea()

            FaceLandmarkOverlay(engine: engine)
                .ignoresSafeArea()

            VStack {
                Spacer()
                Text(L10n.faceRatioIntro)
                    .font(.app(26))
                    .foregroundStyle(Color.appText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 22 * PhoneLayout.metricScale)
                Text(L10n.faceRatioTip)
                    .font(.app(18))
                    .foregroundStyle(Color.appText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 22 * PhoneLayout.metricScale)
                    .padding(.top, 10 * PhoneLayout.metricScale)

                Spacer()

                Text(L10n.faceCartoonNotice)
                    .font(.app(26))
                    .foregroundStyle(Color.appText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 22 * PhoneLayout.metricScale)
                    .padding(.bottom, 18 * PhoneLayout.metricScale)

                Button {
                    captureTapped()
                } label: {
                    Image("camera")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64 * PhoneLayout.metricScale, height: 64 * PhoneLayout.metricScale)
                }
                .disabled(isProcessing)
                .padding(.bottom, max(72, 56 * PhoneLayout.metricScale + 24))
            }

            if isProcessing {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.4)
            }
        }
        .navigationTitle(L10n.faceMeasurerTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { engine.start() }
        .onDisappear { engine.stop() }
        .alert(L10n.toastCaptureFace, isPresented: $showNeedFaceAlert) {
            Button(L10n.btnOk, role: .cancel) {}
        }
    }

    private func captureTapped() {
        guard box.session.hasMinimumLandmarksForCapture else {
            showNeedFaceAlert = true
            return
        }
        guard let frame = engine.latestCartoonFrameForCapture() else {
            showNeedFaceAlert = true
            return
        }
        isProcessing = true
        box.session.cartoonImage = frame
        box.session.recomputeGradeAndScore()
        let posterData = Self.encodePosterImageData(frame)
        engine.stop()
        isProcessing = false
        onCommitted(posterData)
    }

    /// `UIImage` from `CIImage` often has no `jpegData`; re-render into a bitmap-backed image when needed.
    private static func encodePosterImageData(_ image: UIImage) -> Data? {
        if let j = image.jpegData(compressionQuality: 0.9) { return j }
        if let p = image.pngData() { return p }
        let size = image.size
        guard size.width > 1, size.height > 1 else { return nil }
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let bitmap = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return bitmap.jpegData(compressionQuality: 0.9) ?? bitmap.pngData()
    }
}
