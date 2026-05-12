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
    // MARK: - Inputs

    let box: SessionBox
    var onCommitted: (Data?) -> Void
    var onSettingsTapped: () -> Void
    var onHelpTapped: () -> Void

    public init(
        box: SessionBox,
        onCommitted: @escaping (Data?) -> Void,
        onSettingsTapped: @escaping () -> Void,
        onHelpTapped: @escaping () -> Void
    ) {
        self.box = box
        self.onCommitted = onCommitted
        self.onSettingsTapped = onSettingsTapped
        self.onHelpTapped = onHelpTapped
        _engine = StateObject(wrappedValue: FaceCaptureEngine(measureSession: box.session))
    }

    // MARK: - State

    @StateObject private var engine: FaceCaptureEngine
    @ObservedObject private var prefs = VHSEffectsPreferences.shared
    @State private var isProcessing = false
    @State private var showNeedFaceToast = false

    // MARK: - Constants

    private static let topBarHeight: CGFloat = 44
    /// 카메라 viewport (= 포스터 사진 영역) 비율. 1 : 0.82 (landscape).
    private static let viewportAspect: CGFloat = 0.82
    /// 위/아래 컨트롤 영역에 항상 확보해야 할 최소 높이.
    private static let minTopAreaHeight: CGFloat = 90
    private static let minBottomAreaHeight: CGFloat = 170

    // MARK: - Body

    public var body: some View {
        GeometryReader { geo in
            let layout = Layout(canvasSize: geo.size, safeArea: Self.windowSafeArea())

            ZStack {
                cameraStack(size: geo.size)

                CaptureViewportFrame(
                    viewport: layout.viewport,
                    canvasSize: geo.size,
                    dimOpacity: 0.45
                )
                .allowsHitTesting(false)

                // 카메라 영역 안 (viewport 우상단) 에 떠 있는 랜드마크 토글.
                landmarkToggleButton
                    .position(
                        x: layout.viewport.maxX - Self.toggleSize / 2 - 6,
                        y: layout.viewport.minY + Self.toggleSize / 2 + 6
                    )

                // 안내 텍스트 — 비대화형, 항상 hit-test 비활성.
                topInstructionText
                    .frame(width: layout.topArea.width, alignment: .center)
                    .position(x: layout.topArea.midX, y: layout.topArea.midY)
                    .allowsHitTesting(false)

                // 하단 컨트롤 (셔터 + 안내).
                bottomControlsStack
                    .frame(width: layout.bottomArea.width, alignment: .center)
                    .position(x: layout.bottomArea.midX, y: layout.bottomArea.midY)

                if isProcessing {
                    processingOverlay(size: geo.size)
                }

                if showNeedFaceToast {
                    needFaceToast
                        .position(x: geo.size.width / 2, y: layout.viewport.maxY + 28)
                        .transition(.opacity)
                        .allowsHitTesting(false)
                }
            }
            // 최상단 — top bar 는 마지막에 와서 항상 hit-test 우선권을 가짐.
            .overlay(alignment: .top) {
                topBar
                    .padding(.top, layout.safeTop)
            }
        }
        .ignoresSafeArea()
        .onAppear { engine.start() }
        .onDisappear { engine.stop() }
    }

    /// 알림 버튼이 잘 안 눌리는 케이스 대신 사용하는 자동 소멸 토스트.
    @ViewBuilder
    private var needFaceToast: some View {
        Text(L10n.toastCaptureFace)
            .font(.app(14))
            .fontWeight(.semibold)
            .foregroundStyle(Self.ink)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Capsule().fill(Color.black.opacity(0.82)))
            .overlay(Capsule().stroke(Self.ink.opacity(0.4), lineWidth: 1))
            .shadow(color: Color.black.opacity(0.35), radius: 6, y: 3)
    }

    private func showNeedFaceToastTransiently() {
        withAnimation(.easeInOut(duration: 0.18)) {
            showNeedFaceToast = true
        }
        Task {
            try? await Task.sleep(nanoseconds: 1_600_000_000)
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.18)) {
                    showNeedFaceToast = false
                }
            }
        }
    }

    // MARK: - Layers

    @ViewBuilder
    private func cameraStack(size: CGSize) -> some View {
        PreviewLayerHost(previewLayer: engine.previewLayer)
            .frame(width: size.width, height: size.height)
            .allowsHitTesting(false)

        if prefs.showLandmarks {
            FaceLandmarkOverlay(engine: engine)
                .frame(width: size.width, height: size.height)
                .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    private func processingOverlay(size: CGSize) -> some View {
        Color.black.opacity(0.55)
            .frame(width: size.width, height: size.height)
        ProgressView()
            .tint(.white)
            .scaleEffect(1.4)
            .position(x: size.width / 2, y: size.height / 2)
    }

    // MARK: - Top bar

    @ViewBuilder
    private var topBar: some View {
        HStack {
            circleBadge(systemImage: "info.circle.fill", action: onHelpTapped)
                .padding(.leading, 12)
                .accessibilityLabel(L10n.helpScreenTitle)

            Spacer()

            Text(L10n.faceMeasurerTitle)
                .font(.app(16))
                .fontWeight(.semibold)
                .foregroundStyle(Self.ink)
                .lineLimit(1)

            Spacer()

            circleBadge(systemImage: "gearshape.fill", action: onSettingsTapped)
                .padding(.trailing, 12)
                .accessibilityLabel(L10n.settingsTitle)
        }
        .frame(height: Self.topBarHeight)
    }

    @ViewBuilder
    private func circleBadge(systemImage: String, action: @escaping () -> Void) -> some View {
        Image(systemName: systemImage)
            .font(.system(size: 17 * PhoneLayout.metricScale, weight: .semibold))
            .foregroundStyle(Self.ink)
            .frame(width: Self.badgeSize, height: Self.badgeSize)
            .background(Circle().fill(Color.black.opacity(0.45)))
            .overlay(Circle().stroke(Self.ink.opacity(0.55), lineWidth: 1))
            .contentShape(Circle())
            .onTapGesture(perform: action)
            .accessibilityAddTraits(.isButton)
    }

    // MARK: - Top instruction

    @ViewBuilder
    private var topInstructionText: some View {
        Text(L10n.faceRatioIntro)
            .font(.app(20))
            .fontWeight(.heavy)
            .foregroundStyle(Self.ink)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Landmark toggle

    @ViewBuilder
    private var landmarkToggleButton: some View {
        Image(systemName: prefs.showLandmarks ? "eye.fill" : "eye.slash.fill")
            .font(.system(size: 16 * PhoneLayout.metricScale, weight: .semibold))
            .foregroundStyle(Self.ink)
            .frame(width: Self.toggleSize, height: Self.toggleSize)
            .background(Circle().fill(Color.black.opacity(0.45)))
            .overlay(Circle().stroke(Self.ink.opacity(0.55), lineWidth: 1))
            .contentShape(Circle())
            .onTapGesture { prefs.showLandmarks.toggle() }
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(L10n.btnLandmarksToggle)
    }

    // MARK: - Bottom controls

    @ViewBuilder
    private var bottomControlsStack: some View {
        VStack(spacing: 14 * PhoneLayout.metricScale) {
            Text(L10n.faceCartoonNotice)
                .font(.app(13))
                .foregroundStyle(Self.ink.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            shutterButton
        }
    }

    @ViewBuilder
    private var shutterButton: some View {
        let size: CGFloat = 82 * PhoneLayout.metricScale
        ZStack {
            Circle().fill(Color.black.opacity(0.55)).frame(width: size, height: size)
            Circle().stroke(Self.ink, lineWidth: 3.5 * PhoneLayout.metricScale).frame(width: size, height: size)
            Image("camera")
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .foregroundStyle(Self.ink)
                .frame(width: 40 * PhoneLayout.metricScale, height: 40 * PhoneLayout.metricScale)
        }
        .contentShape(Circle())
        .onTapGesture {
            guard !isProcessing else { return }
            captureTapped()
        }
        .accessibilityAddTraits(.isButton)
        .glitchRGB(active: isProcessing, intensity: 1.2, duration: 0.35)
    }

    // MARK: - Capture flow

    private func captureTapped() {
        guard box.session.hasMinimumLandmarksForCapture else {
            showNeedFaceToastTransiently()
            return
        }
        guard let frame = engine.latestCartoonFrameForCapture() else {
            showNeedFaceToastTransiently()
            return
        }
        isProcessing = true
        let viewport = Layout(
            canvasSize: CGSize(width: engine.previewLayer.bounds.width, height: engine.previewLayer.bounds.height),
            safeArea: Self.windowSafeArea()
        ).viewport
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

    // MARK: - Layout helpers

    /// 한 번 계산하면 4개 영역(top bar / top text / viewport / bottom) 좌표를 모두 제공.
    private struct Layout {
        let canvasSize: CGSize
        let safeTop: CGFloat
        let safeBottom: CGFloat
        let viewport: CGRect
        let topArea: CGRect
        let bottomArea: CGRect

        init(canvasSize: CGSize, safeArea: UIEdgeInsets) {
            self.canvasSize = canvasSize
            guard canvasSize.width > 1, canvasSize.height > 1 else {
                self.safeTop = 0
                self.safeBottom = 0
                self.viewport = .zero
                self.topArea = .zero
                self.bottomArea = .zero
                return
            }
            self.safeTop = max(0, safeArea.top)
            self.safeBottom = max(0, safeArea.bottom)

            let topBarBottom = self.safeTop + FaceCaptureView.topBarHeight
            let availBottom = max(topBarBottom, canvasSize.height - self.safeBottom)
            let availHeight = max(0, availBottom - topBarBottom)

            // viewport — 화면 가로의 일정 비율 안에서 1:0.82 비율, 위/아래 컨트롤 공간 확보.
            let padX: CGFloat = 18 * PhoneLayout.metricScale
            let widthBase = max(0, canvasSize.width - padX * 2)
            let heightFromWidth = widthBase * FaceCaptureView.viewportAspect
            let heightAfterReserves = max(
                0,
                availHeight - FaceCaptureView.minTopAreaHeight - FaceCaptureView.minBottomAreaHeight
            )
            let viewportHeight = min(heightFromWidth, heightAfterReserves)
            let viewportWidth = viewportHeight / FaceCaptureView.viewportAspect

            // 세로 중앙보다 살짝 위로 — 하단 셔터 공간을 더 확보.
            let rawY = topBarBottom + (availHeight - viewportHeight) / 2
            let liftedY = rawY - 10 * PhoneLayout.metricScale
            let clampedY = max(topBarBottom + 12, min(liftedY, availBottom - viewportHeight - 12))
            let viewportX = (canvasSize.width - viewportWidth) / 2

            self.viewport = CGRect(x: viewportX, y: clampedY, width: viewportWidth, height: viewportHeight)

            let textPadX: CGFloat = 24 * PhoneLayout.metricScale
            self.topArea = CGRect(
                x: textPadX,
                y: topBarBottom,
                width: max(0, canvasSize.width - textPadX * 2),
                height: max(0, self.viewport.minY - topBarBottom)
            )
            self.bottomArea = CGRect(
                x: textPadX,
                y: self.viewport.maxY,
                width: max(0, canvasSize.width - textPadX * 2),
                height: max(0, availBottom - self.viewport.maxY)
            )
        }
    }

    /// `ignoresSafeArea` 적용된 GeometryReader 안에서는 `geo.safeAreaInsets` 가 0 으로
    /// 보고될 수 있어, 키 윈도우의 실제 safe area 를 직접 조회.
    private static func windowSafeArea() -> UIEdgeInsets {
        for scene in UIApplication.shared.connectedScenes {
            guard let ws = scene as? UIWindowScene else { continue }
            if let key = ws.windows.first(where: { $0.isKeyWindow }) {
                return key.safeAreaInsets
            }
            if let first = ws.windows.first {
                return first.safeAreaInsets
            }
        }
        return .zero
    }

    // MARK: - Style constants

    private static let ink = Color(white: 0.96)
    private static let badgeSize: CGFloat = 38 * PhoneLayout.metricScale
    private static let toggleSize: CGFloat = 38 * PhoneLayout.metricScale

    // MARK: - Image processing

    private static func cropToViewport(
        image: UIImage,
        viewport: CGRect,
        previewLayer: AVCaptureVideoPreviewLayer
    ) -> UIImage? {
        guard viewport.width > 1, viewport.height > 1 else { return nil }
        let layerBounds = previewLayer.bounds
        guard layerBounds.width > 1, layerBounds.height > 1 else { return nil }

        guard let cg = renderCGImage(image) else { return nil }
        let imgW = CGFloat(cg.width)
        let imgH = CGFloat(cg.height)

        // .resizeAspectFill 매핑을 직접 풀어 viewport ↔ 픽셀 좌표 정합.
        let scale = max(layerBounds.width / imgW, layerBounds.height / imgH)
        let offsetX = (layerBounds.width - imgW * scale) / 2
        let offsetY = (layerBounds.height - imgH * scale) / 2

        let cropRect = CGRect(
            x: (viewport.minX - offsetX) / scale,
            y: (viewport.minY - offsetY) / scale,
            width: viewport.width / scale,
            height: viewport.height / scale
        ).intersection(CGRect(x: 0, y: 0, width: imgW, height: imgH))

        guard cropRect.width > 1, cropRect.height > 1, let cropped = cg.cropping(to: cropRect) else { return nil }
        return UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
    }

    private static func renderCGImage(_ image: UIImage) -> CGImage? {
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
