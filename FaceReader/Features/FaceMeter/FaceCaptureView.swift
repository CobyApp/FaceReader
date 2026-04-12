//
//  FaceCaptureView.swift
//  FaceReader
//

import FaceReaderLocalization
import SwiftUI

struct FaceCaptureView: View {
    let box: SessionBox
    var onCommitted: () -> Void
    var onEditNickname: () -> Void
    var onDismiss: () -> Void

    @StateObject private var engine: FaceCaptureEngine
    @State private var isProcessing = false
    @State private var showNeedFaceAlert = false

    init(
        box: SessionBox,
        onCommitted: @escaping () -> Void,
        onEditNickname: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.box = box
        self.onCommitted = onCommitted
        self.onEditNickname = onEditNickname
        self.onDismiss = onDismiss
        _engine = StateObject(wrappedValue: FaceCaptureEngine(measureSession: box.session))
    }

    var body: some View {
        ZStack {
            PreviewLayerHost(previewLayer: engine.previewLayer)
                .ignoresSafeArea()

            VStack {
                Spacer()
                Text(L10n.faceRatioIntro)
                    .font(.app(24))
                    .foregroundStyle(Color.appText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                Text(L10n.faceRatioTip)
                    .font(.app(17))
                    .foregroundStyle(Color.appText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                Spacer()

                Text(L10n.faceCartoonNotice)
                    .font(.app(24))
                    .foregroundStyle(Color.appText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                Button {
                    captureTapped()
                } label: {
                    Image("camera")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                .disabled(isProcessing)
                .padding(.bottom, 80)
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
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.appText)
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    onEditNickname()
                } label: {
                    Image(systemName: "pencil")
                        .foregroundStyle(Color.appText)
                }
            }
        }
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
        isProcessing = true
        box.session.cartoonImage = box.session.faceImage
        box.session.recomputeGradeAndScore()
        isProcessing = false
        onCommitted()
    }
}
