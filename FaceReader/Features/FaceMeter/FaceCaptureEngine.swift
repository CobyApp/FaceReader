//
//  FaceCaptureEngine.swift
//  FaceReader
//

import AVFoundation
import Combine
import CoreImage
import UIKit
import Vision

/// Owns `AVCaptureSession`, Vision landmarks, and writes into `FaceMeasureSession`.
final class FaceCaptureEngine: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let measureSession: FaceMeasureSession

    private let sequenceHandler = VNSequenceRequestHandler()
    private let session = AVCaptureSession()
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
        configureIfNeeded()
        guard !session.isRunning else { return }
        session.startRunning()
    }

    func stop() {
        session.stopRunning()
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
        videoOutput.connection(with: .video)?.videoOrientation = .portrait
    }

    func captureOutput(_: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from _: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let ciimage = CIImage(cvPixelBuffer: imageBuffer)
        measureSession.faceImage = Self.convert(cmage: ciimage)

        let detectFaceRequest = VNDetectFaceLandmarksRequest(completionHandler: detectedFace)
        do {
            try sequenceHandler.perform([detectFaceRequest], on: imageBuffer, orientation: .leftMirrored)
        } catch {
            print(error.localizedDescription)
        }
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
        return previewLayer.layerPointConverted(fromCaptureDevicePoint: absolute)
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
    }

    private static func convert(cmage: CIImage) -> UIImage {
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(cmage, from: cmage.extent)!
        let ciImage = CIImage(cgImage: cgImage).applyingFilter("CIComicEffect")
        return UIImage(ciImage: ciImage)
    }
}
