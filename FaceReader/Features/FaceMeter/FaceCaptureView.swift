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
                    dimOpacity: 0.45
                )

                topInstruction(m: m)
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
        guard full.width > 1, full.height > 1 else {
            return Metrics(fullSize: full, viewport: .zero, topAreaRect: .zero, bottomAreaRect: .zero)
        }
        let safe = geo.safeAreaInsets
        let availTop = max(0, safe.top)
        let availBottom = max(availTop, full.height - max(0, safe.bottom))
        let availHeight = max(0, availBottom - availTop)

        // viewport: 가로 90% · 1:0.82 (포스터 face 프레임 비율)
        // 위/아래 컨트롤 공간을 위해 viewport height 상한 둠.
        let padX: CGFloat = 18 * PhoneLayout.metricScale
        let widthBase = max(0, full.width - padX * 2)
        let heightFromWidth = widthBase * 0.82
        // 위 약 100pt(타이틀), 아래 약 180pt(셔터+여백) 확보
        let maxByHeight = max(0, availHeight - 280)
        let viewportHeight = min(heightFromWidth, maxByHeight)
        let viewportWidth = viewportHeight / 0.82  // aspect 유지

        // 세이프 영역 안에서 중앙 정렬, 하단 컨트롤 공간이 조금 더 크도록 살짝 위로
        let rawY = availTop + (availHeight - viewportHeight) / 2
        let viewportY = max(availTop + 12, min(rawY - 10 * PhoneLayout.metricScale, availBottom - viewportHeight - 12))
        let viewportX = (full.width - viewportWidth) / 2
        let viewport = CGRect(x: viewportX, y: viewportY, width: viewportWidth, height: viewportHeight)

        let textPadX: CGFloat = 24 * PhoneLayout.metricScale
        let topRect = CGRect(
            x: textPadX,
            y: availTop,
            width: max(0, full.width - textPadX * 2),
            height: max(0, viewport.minY - availTop)
        )
        let bottomRect = CGRect(
            x: textPadX,
            y: viewport.maxY,
            width: max(0, full.width - textPadX * 2),
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
    private func topInstruction(m: Metrics) -> some View {
        let ink = Color(white: 0.96)
        Text(L10n.faceRatioIntro)
            .font(.app(20))
            .fontWeight(.heavy)
            .foregroundStyle(ink)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .frame(width: m.topAreaRect.width, alignment: .center)
            .position(x: m.topAreaRect.midX, y: m.topAreaRect.midY)
    }

    @ViewBuilder
    private func bottomControls(m: Metrics) -> some View {
        let ink = Color(white: 0.96)
        let viewport = m.viewport
        VStack(spacing: 14 * PhoneLayout.metricScale) {
            Text(L10n.faceCartoonNotice)
                .font(.app(13))
                .foregroundStyle(ink.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                captureTapped(viewport: viewport)
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.55))
                        .frame(width: 82 * PhoneLayout.metricScale, height: 82 * PhoneLayout.metricScale)
                    Circle()
                        .stroke(ink, lineWidth: 3.5 * PhoneLayout.metricScale)
                        .frame(width: 82 * PhoneLayout.metricScale, height: 82 * PhoneLayout.metricScale)
                    Image("camera")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .foregroundStyle(ink)
                        .frame(width: 40 * PhoneLayout.metricScale, height: 40 * PhoneLayout.metricScale)
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

    /// viewport (preview layer 좌표) 영역에 해당하는 cartoon 이미지 픽셀 영역을 직접 계산해서 잘라 반환.
    /// `.resizeAspectFill` 매핑을 명시적으로 풀어, 화면에서 보이는 viewport 영역과 동일한
    /// 픽셀 범위를 정확히 잘라낸다.
    private static func cropToViewport(
        image: UIImage,
        viewport: CGRect,
        previewLayer: AVCaptureVideoPreviewLayer
    ) -> UIImage? {
        guard viewport.width > 1, viewport.height > 1 else { return nil }
        let layerBounds = previewLayer.bounds
        guard layerBounds.width > 1, layerBounds.height > 1 else { return nil }

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
        let imgW = CGFloat(cg.width)
        let imgH = CGFloat(cg.height)

        // `.resizeAspectFill`: 이미지를 layer 에 꽉 채우도록 max scale 로 키움.
        let scale = max(layerBounds.width / imgW, layerBounds.height / imgH)
        let displayedW = imgW * scale
        let displayedH = imgH * scale
        // 키운 이미지가 layer 보다 클 때 음수 offset (양쪽으로 잘려나가는 양만큼).
        let offsetX = (layerBounds.width - displayedW) / 2
        let offsetY = (layerBounds.height - displayedH) / 2

        // viewport (layer 좌표) → 키운 이미지 좌표 → 원본 픽셀 좌표.
        let cropX = (viewport.minX - offsetX) / scale
        let cropY = (viewport.minY - offsetY) / scale
        let cropW = viewport.width / scale
        let cropH = viewport.height / scale

        let cropRect = CGRect(x: cropX, y: cropY, width: cropW, height: cropH)
            .intersection(CGRect(x: 0, y: 0, width: imgW, height: imgH))
        guard cropRect.width > 1, cropRect.height > 1, let cropped = cg.cropping(to: cropRect) else { return nil }
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
