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
        GeometryReader { geo in
            let viewport = Self.viewportRect(in: geo.size)
            ZStack(alignment: .top) {
                PreviewLayerHost(previewLayer: engine.previewLayer)
                    .ignoresSafeArea()

                FaceLandmarkOverlay(engine: engine)
                    .ignoresSafeArea()

                CaptureViewportFrame(
                    viewport: viewport,
                    canvasSize: geo.size,
                    dimOpacity: 0.78
                )

                topInstructions(viewport: viewport)
                bottomControls(viewport: viewport, screenHeight: geo.size.height)

                if isProcessing {
                    Color.black.opacity(0.55)
                        .ignoresSafeArea()
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.4)
                }
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

    // MARK: - Layout

    /// 포스터 face 프레임 비율(1 : 0.82)을 화면 가운데에 맞춤.
    private static func viewportRect(in size: CGSize) -> CGRect {
        let padX: CGFloat = 16 * PhoneLayout.metricScale
        let width = size.width - padX * 2
        let height = width * 0.82
        let x = padX
        let y = (size.height - height) / 2
        return CGRect(x: x, y: y, width: width, height: height)
    }

    @ViewBuilder
    private func topInstructions(viewport: CGRect) -> some View {
        let ink = Color(white: 0.96)
        VStack(spacing: 10 * PhoneLayout.metricScale) {
            Text(L10n.faceRatioIntro)
                .font(.app(22))
                .fontWeight(.heavy)
                .foregroundStyle(ink)
            Text(L10n.faceRatioTip)
                .font(.app(14))
                .foregroundStyle(ink.opacity(0.85))
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 28 * PhoneLayout.metricScale)
        .frame(maxWidth: .infinity)
        .padding(.top, 12 * PhoneLayout.metricScale)
        .frame(height: viewport.minY, alignment: .center)
    }

    @ViewBuilder
    private func bottomControls(viewport: CGRect, screenHeight: CGFloat) -> some View {
        let ink = Color(white: 0.96)
        VStack(spacing: 18 * PhoneLayout.metricScale) {
            Text(L10n.faceCartoonNotice)
                .font(.app(15))
                .foregroundStyle(ink.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 16 * PhoneLayout.metricScale)

            Button {
                captureTapped()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.7))
                        .frame(width: 84 * PhoneLayout.metricScale, height: 84 * PhoneLayout.metricScale)
                    Circle()
                        .stroke(ink, lineWidth: 4 * PhoneLayout.metricScale)
                        .frame(width: 84 * PhoneLayout.metricScale, height: 84 * PhoneLayout.metricScale)
                    Image("camera")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .foregroundStyle(ink)
                        .frame(width: 44 * PhoneLayout.metricScale, height: 44 * PhoneLayout.metricScale)
                }
            }
            .disabled(isProcessing)
            .glitchRGB(active: isProcessing, intensity: 1.2, duration: 0.35)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24 * PhoneLayout.metricScale)
        .padding(.bottom, 40 * PhoneLayout.metricScale)
        .frame(
            height: max(screenHeight - viewport.maxY, 200),
            alignment: .top
        )
        .offset(y: viewport.maxY)
    }

    // MARK: - Capture

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
