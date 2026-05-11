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
    var onSettingsTapped: () -> Void

    @StateObject private var engine: FaceCaptureEngine
    @ObservedObject private var prefs = VHSEffectsPreferences.shared
    @State private var isProcessing = false
    @State private var showNeedFaceAlert = false

    public init(
        box: SessionBox,
        onCommitted: @escaping (Data?) -> Void,
        onSettingsTapped: @escaping () -> Void
    ) {
        self.box = box
        self.onCommitted = onCommitted
        self.onSettingsTapped = onSettingsTapped
        _engine = StateObject(wrappedValue: FaceCaptureEngine(measureSession: box.session))
    }

    private static let topBarHeight: CGFloat = 44

    public var body: some View {
        GeometryReader { geo in
            let m = Self.metrics(in: geo)
            ZStack(alignment: .topLeading) {
                PreviewLayerHost(previewLayer: engine.previewLayer)
                    .frame(width: m.fullSize.width, height: m.fullSize.height)

                if prefs.showLandmarks {
                    FaceLandmarkOverlay(engine: engine)
                        .frame(width: m.fullSize.width, height: m.fullSize.height)
                }

                CaptureViewportFrame(
                    viewport: m.viewport,
                    canvasSize: m.fullSize,
                    dimOpacity: 0.45
                )

                topBar(m: m)
                topInstruction(m: m)
                landmarkToggle(m: m)
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
        let topBarRect: CGRect      // 상단 커스텀 bar (status bar 제외)
        let topAreaRect: CGRect     // bar 아래 ~ viewport 위
        let bottomAreaRect: CGRect  // viewport 아래 ~ home indicator 위
        let safeTop: CGFloat
    }

    private static func windowSafeArea() -> UIEdgeInsets {
        for scene in UIApplication.shared.connectedScenes {
            guard let ws = scene as? UIWindowScene else { continue }
            for window in ws.windows where window.isKeyWindow {
                return window.safeAreaInsets
            }
            if let first = ws.windows.first {
                return first.safeAreaInsets
            }
        }
        return .zero
    }

    private static func metrics(in geo: GeometryProxy) -> Metrics {
        let full = geo.size
        guard full.width > 1, full.height > 1 else {
            return Metrics(fullSize: full, viewport: .zero, topBarRect: .zero, topAreaRect: .zero, bottomAreaRect: .zero, safeTop: 0)
        }
        // ignoresSafeArea 영향으로 geo.safeAreaInsets 이 0 으로 보고될 수 있어 window 에서 직접 조회.
        let window = windowSafeArea()
        let safeTop = max(geo.safeAreaInsets.top, window.top)
        let safeBottom = max(geo.safeAreaInsets.bottom, window.bottom)
        let topBarBottom = safeTop + topBarHeight
        let availTop = topBarBottom
        let availBottom = max(availTop, full.height - safeBottom)
        let availHeight = max(0, availBottom - availTop)

        let padX: CGFloat = 18 * PhoneLayout.metricScale
        let widthBase = max(0, full.width - padX * 2)
        let heightFromWidth = widthBase * 0.82
        let maxByHeight = max(0, availHeight - 260)
        let viewportHeight = min(heightFromWidth, maxByHeight)
        let viewportWidth = viewportHeight / 0.82

        let rawY = availTop + (availHeight - viewportHeight) / 2
        let viewportY = max(availTop + 12, min(rawY - 10 * PhoneLayout.metricScale, availBottom - viewportHeight - 12))
        let viewportX = (full.width - viewportWidth) / 2
        let viewport = CGRect(x: viewportX, y: viewportY, width: viewportWidth, height: viewportHeight)

        let topBarRect = CGRect(x: 0, y: safeTop, width: full.width, height: topBarHeight)
        let textPadX: CGFloat = 24 * PhoneLayout.metricScale
        let topRect = CGRect(
            x: textPadX,
            y: topBarBottom,
            width: max(0, full.width - textPadX * 2),
            height: max(0, viewport.minY - topBarBottom)
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
            topBarRect: topBarRect,
            topAreaRect: topRect,
            bottomAreaRect: bottomRect,
            safeTop: safeTop
        )
    }

    @ViewBuilder
    private func topBar(m: Metrics) -> some View {
        let ink = Color(white: 0.96)
        let badgeSize: CGFloat = 38 * PhoneLayout.metricScale
        ZStack {
            Text(L10n.faceMeasurerTitle)
                .font(.app(16))
                .fontWeight(.semibold)
                .foregroundStyle(ink)
                .frame(maxWidth: .infinity)

            HStack {
                Spacer()
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 17 * PhoneLayout.metricScale, weight: .semibold))
                    .foregroundStyle(ink)
                    .frame(width: badgeSize, height: badgeSize)
                    .background(Circle().fill(Color.black.opacity(0.45)))
                    .overlay(Circle().stroke(ink.opacity(0.55), lineWidth: 1))
                    .contentShape(Circle())
                    .onTapGesture { onSettingsTapped() }
                    .padding(.trailing, 12)
                    .accessibilityAddTraits(.isButton)
                    .accessibilityLabel(L10n.settingsTitle)
            }
        }
        .frame(width: m.topBarRect.width, height: m.topBarRect.height)
        .position(x: m.topBarRect.midX, y: m.topBarRect.midY)
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
    private func landmarkToggle(m: Metrics) -> some View {
        let ink = Color(white: 0.96)
        let size: CGFloat = 38 * PhoneLayout.metricScale
        Image(systemName: prefs.showLandmarks ? "eye.fill" : "eye.slash.fill")
            .font(.system(size: 16 * PhoneLayout.metricScale, weight: .semibold))
            .foregroundStyle(ink)
            .frame(width: size, height: size)
            .background(Circle().fill(Color.black.opacity(0.45)))
            .overlay(Circle().stroke(ink.opacity(0.55), lineWidth: 1))
            .contentShape(Circle())
            .onTapGesture {
                prefs.showLandmarks.toggle()
            }
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(L10n.btnLandmarksToggle)
            .position(
                x: m.viewport.maxX - size / 2 - 4,
                y: m.viewport.minY + size / 2 + 4
            )
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
            .contentShape(Circle())
            .onTapGesture {
                guard !isProcessing else { return }
                captureTapped(viewport: viewport)
            }
            .accessibilityAddTraits(.isButton)
            .glitchRGB(active: isProcessing, intensity: 1.2, duration: 0.35)
        }
        .frame(width: m.bottomAreaRect.width, alignment: .center)
        .position(x: m.bottomAreaRect.midX, y: m.bottomAreaRect.midY)
    }

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

        let scale = max(layerBounds.width / imgW, layerBounds.height / imgH)
        let displayedW = imgW * scale
        let displayedH = imgH * scale
        let offsetX = (layerBounds.width - displayedW) / 2
        let offsetY = (layerBounds.height - displayedH) / 2

        let cropX = (viewport.minX - offsetX) / scale
        let cropY = (viewport.minY - offsetY) / scale
        let cropW = viewport.width / scale
        let cropH = viewport.height / scale

        let cropRect = CGRect(x: cropX, y: cropY, width: cropW, height: cropH)
            .intersection(CGRect(x: 0, y: 0, width: imgW, height: imgH))
        guard cropRect.width > 1, cropRect.height > 1, let cropped = cg.cropping(to: cropRect) else { return nil }
        return UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
    }

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
