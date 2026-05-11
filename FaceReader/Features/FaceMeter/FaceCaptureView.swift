//
//  FaceCaptureView.swift
//  FaceReader
//

import AVFoundation
import CoreImage
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
            let m = Self.metrics(in: geo)
            ZStack(alignment: .topLeading) {
                PreviewLayerHost(previewLayer: engine.previewLayer)
                    .frame(width: m.fullSize.width, height: m.fullSize.height)

                FaceLandmarkOverlay(engine: engine)
                    .frame(width: m.fullSize.width, height: m.fullSize.height)

                CaptureViewportFrame(
                    viewport: m.viewport,
                    canvasSize: m.fullSize,
                    dimOpacity: 0.78
                )

                topInstructions(m: m)
                bottomControls(m: m)

                if isProcessing {
                    Color.black.opacity(0.55)
                        .frame(width: m.fullSize.width, height: m.fullSize.height)
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.4)
                        .position(x: m.fullSize.width / 2, y: m.fullSize.height / 2)
                }
            }
        }
        .ignoresSafeArea()
        .navigationTitle(L10n.faceMeasurerTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { engine.start() }
        .onDisappear { engine.stop() }
        .alert(L10n.toastCaptureFace, isPresented: $showNeedFaceAlert) {
            Button(L10n.btnOk, role: .cancel) {}
        }
    }

    // MARK: - Layout metrics

    private struct Metrics {
        let fullSize: CGSize
        let viewport: CGRect
        let topAreaRect: CGRect
        let bottomAreaRect: CGRect
    }

    private static func metrics(in geo: GeometryProxy) -> Metrics {
        let full = geo.size
        let safe = geo.safeAreaInsets
        let availTop = safe.top
        let availBottom = full.height - safe.bottom

        let padX: CGFloat = 18 * PhoneLayout.metricScale
        let viewportWidth = full.width - padX * 2
        let viewportHeight = viewportWidth * 0.82
        let availHeight = availBottom - availTop
        let rawY = availTop + (availHeight - viewportHeight) / 2
        // 위 텍스트가 최소 한 줄 공간 확보되도록 살짝 아래로 (1/3 지점 부근)
        let pushDown: CGFloat = max(0, (availHeight - viewportHeight) * 0.15)
        let viewportY = min(max(rawY + pushDown, availTop + 80), availBottom - viewportHeight - 12)
        let viewport = CGRect(x: padX, y: viewportY, width: viewportWidth, height: viewportHeight)

        let textPadX: CGFloat = 22 * PhoneLayout.metricScale
        let topRect = CGRect(
            x: textPadX,
            y: availTop,
            width: full.width - textPadX * 2,
            height: max(0, viewport.minY - availTop)
        )
        let bottomRect = CGRect(
            x: textPadX,
            y: viewport.maxY,
            width: full.width - textPadX * 2,
            height: max(0, availBottom - viewport.maxY)
        )

        return Metrics(
            fullSize: full,
            viewport: viewport,
            topAreaRect: topRect,
            bottomAreaRect: bottomRect
        )
    }

    @ViewBuilder
    private func topInstructions(m: Metrics) -> some View {
        let ink = Color(white: 0.96)
        VStack(spacing: 8 * PhoneLayout.metricScale) {
            Text(L10n.faceRatioIntro)
                .font(.app(22))
                .fontWeight(.heavy)
                .foregroundStyle(ink)
            Text(L10n.faceRatioTip)
                .font(.app(13))
                .foregroundStyle(ink.opacity(0.85))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .multilineTextAlignment(.center)
        .frame(width: m.topAreaRect.width, alignment: .center)
        .position(x: m.topAreaRect.midX, y: m.topAreaRect.midY)
    }

    @ViewBuilder
    private func bottomControls(m: Metrics) -> some View {
        let ink = Color(white: 0.96)
        let viewport = m.viewport
        VStack(spacing: 16 * PhoneLayout.metricScale) {
            Text(L10n.faceCartoonNotice)
                .font(.app(14))
                .foregroundStyle(ink.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                captureTapped(viewport: viewport)
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.7))
                        .frame(width: 80 * PhoneLayout.metricScale, height: 80 * PhoneLayout.metricScale)
                    Circle()
                        .stroke(ink, lineWidth: 4 * PhoneLayout.metricScale)
                        .frame(width: 80 * PhoneLayout.metricScale, height: 80 * PhoneLayout.metricScale)
                    Image("camera")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .foregroundStyle(ink)
                        .frame(width: 42 * PhoneLayout.metricScale, height: 42 * PhoneLayout.metricScale)
                }
            }
            .disabled(isProcessing)
            .glitchRGB(active: isProcessing, intensity: 1.2, duration: 0.35)
        }
        .frame(width: m.bottomAreaRect.width, alignment: .center)
        .position(x: m.bottomAreaRect.midX, y: m.bottomAreaRect.midY)
    }

    // MARK: - Capture

    private func captureTapped(viewport: CGRect) {
        guard box.session.hasMinimumLandmarksForCapture else {
            showNeedFaceAlert = true
            return
        }
        guard let frame = engine.latestCartoonFrameForCapture() else {
            showNeedFaceAlert = true
            return
        }
        isProcessing = true
        let cropped = Self.cropToViewport(
            image: frame,
            viewport: viewport,
            previewLayer: engine.previewLayer
        ) ?? frame
        box.session.cartoonImage = cropped
        box.session.recomputeGradeAndScore()
        let posterData = Self.encodePosterImageData(cropped)
        engine.stop()
        isProcessing = false
        onCommitted(posterData)
    }

    /// viewport (preview layer 좌표) 영역에 해당하는 capture 출력 부분만 잘라 반환.
    /// `metadataOutputRectConverted`가 `videoGravity = .resizeAspectFill`을 고려해 정규화 좌표를 계산.
    private static func cropToViewport(
        image: UIImage,
        viewport: CGRect,
        previewLayer: AVCaptureVideoPreviewLayer
    ) -> UIImage? {
        guard viewport.width > 1, viewport.height > 1 else { return nil }
        let normalized = previewLayer.metadataOutputRectConverted(fromLayerRect: viewport)
        guard normalized.width > 0, normalized.height > 0 else { return nil }

        let cgImage: CGImage? = {
            if let cg = image.cgImage { return cg }
            if let ci = image.ciImage {
                return CIContext().createCGImage(ci, from: ci.extent)
            }
            let format = UIGraphicsImageRendererFormat()
            format.scale = image.scale
            format.opaque = false
            let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
            return renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: image.size))
            }.cgImage
        }()

        guard let cg = cgImage else { return nil }
        let w = CGFloat(cg.width)
        let h = CGFloat(cg.height)
        let rawCrop = CGRect(
            x: normalized.origin.x * w,
            y: normalized.origin.y * h,
            width: normalized.width * w,
            height: normalized.height * h
        )
        let clamped = rawCrop.intersection(CGRect(x: 0, y: 0, width: w, height: h))
        guard clamped.width > 1, clamped.height > 1, let cropped = cg.cropping(to: clamped) else { return nil }
        return UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
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
