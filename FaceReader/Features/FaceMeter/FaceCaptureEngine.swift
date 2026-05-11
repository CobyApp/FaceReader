//
//  FaceCaptureEngine.swift
//  FaceReader
//

import AVFoundation
import Combine
import CoreImage
import CoreVideo
import FaceReaderCore
import UIKit
import Vision

/// Owns `AVCaptureSession`, Vision landmarks, and writes into `FaceMeasureSession`.
final class FaceCaptureEngine: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let measureSession: FaceMeasureSession

    private let sequenceHandler = VNSequenceRequestHandler()
    private let session = AVCaptureSession()
    /// Serial queue for `AVCaptureSession` configuration and `startRunning` / `stopRunning` (must not block the main thread).
    private let sessionQueue = DispatchQueue(label: "face.capture.session", qos: .userInitiated)
    private let dataOutputQueue = DispatchQueue(label: "face.capture.video", qos: .userInitiated)

    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        return layer
    }()

    private var didConfigure = false

    init(measureSession: FaceMeasureSession) {
        self.measureSession = measureSession
        super.init()
    }

    func start() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.configureIfNeeded()
            guard !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            guard self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }

    /// Latest comic-filtered frame from the video callback. Call from main: uses `dataOutputQueue` so the read matches what the pipeline last wrote (avoids racing `faceImage` updates).
    func latestCartoonFrameForCapture() -> UIImage? {
        var image: UIImage?
        dataOutputQueue.sync { [weak self] in
            image = self?.measureSession.faceImage
        }
        return image
    }

    private func configureIfNeeded() {
        guard !didConfigure else { return }
        didConfigure = true

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            return
        }

        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            session.addInput(cameraInput)
        } catch {
            return
        }

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        session.addOutput(videoOutput)

        let rotation = AVCaptureDevice.RotationCoordinator(device: camera, previewLayer: previewLayer)
        if let outConn = videoOutput.connection(with: .video) {
            outConn.videoRotationAngle = rotation.videoRotationAngleForHorizonLevelCapture
            outConn.automaticallyAdjustsVideoMirroring = false
            outConn.isVideoMirrored = true
        }
        if let prevConn = previewLayer.connection {
            prevConn.videoRotationAngle = rotation.videoRotationAngleForHorizonLevelPreview
            prevConn.automaticallyAdjustsVideoMirroring = false
            prevConn.isVideoMirrored = true
        }
    }

    func captureOutput(_: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from _: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let ciimage = CIImage(cvPixelBuffer: imageBuffer)
        measureSession.faceImage = Self.convert(cmage: ciimage)

        let detectFaceRequest = VNDetectFaceLandmarksRequest(completionHandler: detectedFace)
        let exifOrientation = Self.visionOrientation(forFrontCameraPixelBuffer: imageBuffer)
        do {
            try sequenceHandler.perform([detectFaceRequest], on: imageBuffer, orientation: exifOrientation)
        } catch {
            print(error.localizedDescription)
        }
    }

    /// Vision `orientation` must match how pixel rows map to upright preview. Portrait-sized buffers need `.upMirrored`; landscape buffers (sensor-native) need `.leftMirrored` for front + portrait UI.
    private static func visionOrientation(forFrontCameraPixelBuffer pixelBuffer: CVPixelBuffer) -> CGImagePropertyOrientation {
        let w = CVPixelBufferGetWidth(pixelBuffer)
        let h = CVPixelBufferGetHeight(pixelBuffer)
        let isPortraitPixels = h > w
        return isPortraitPixels ? .upMirrored : .leftMirrored
    }

    private func detectedFace(request: VNRequest, error: Error?) {
        guard error == nil,
              let results = request.results as? [VNFaceObservation],
              let result = results.first
        else { return }

        DispatchQueue.main.async {
            self.updateFaceView(for: result)
        }
    }

    private func landmark(point: CGPoint, to rect: CGRect) -> CGPoint {
        let absolute = point.absolutePoint(in: rect)
        // Vision uses bottom-left origin; `layerPointConverted(fromCaptureDevicePoint:)` expects top-left normalized space.
        let deviceNormalized = CGPoint(x: absolute.x, y: 1.0 - absolute.y)
        return previewLayer.layerPointConverted(fromCaptureDevicePoint: deviceNormalized)
    }

    private func landmark(points: [CGPoint]?, to rect: CGRect) -> [CGPoint]? {
        points.map { $0.compactMap { landmark(point: $0, to: rect) } }
    }

    private func updateFaceView(for result: VNFaceObservation) {
        guard let landmarks = result.landmarks else { return }
        let box = result.boundingBox

        if let v = landmark(points: landmarks.leftEye?.normalizedPoints, to: box) {
            measureSession.leftEye = v
        }
        if let v = landmark(points: landmarks.rightEye?.normalizedPoints, to: box) {
            measureSession.rightEye = v
        }
        if let v = landmark(points: landmarks.leftEyebrow?.normalizedPoints, to: box) {
            measureSession.leftEyebrow = v
        }
        if let v = landmark(points: landmarks.rightEyebrow?.normalizedPoints, to: box) {
            measureSession.rightEyebrow = v
        }
        if let v = landmark(points: landmarks.nose?.normalizedPoints, to: box) {
            measureSession.nose = v
        }
        if let v = landmark(points: landmarks.outerLips?.normalizedPoints, to: box) {
            measureSession.outerLips = v
        }
        if let v = landmark(points: landmarks.innerLips?.normalizedPoints, to: box) {
            measureSession.innerLips = v
        }
        if let v = landmark(points: landmarks.faceContour?.normalizedPoints, to: box) {
            measureSession.faceContour = v
        }

        objectWillChange.send()
    }

    private static func convert(cmage: CIImage) -> UIImage {
        let originalExtent = cmage.extent
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(cmage, from: originalExtent)!
        // CIComicEffect는 가장자리 처리 때문에 약간 확장된 extent 를 반환할 수 있어,
        // 잘라서 원본 버퍼 extent 와 동일하게 맞춰야 viewport 크롭 좌표가 정확히 들어맞음.
        let ciImage = CIImage(cgImage: cgImage)
            .applyingFilter("CIComicEffect")
            .cropped(to: originalExtent)
        return UIImage(ciImage: ciImage)
    }
}
