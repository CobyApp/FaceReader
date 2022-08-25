//
//  MainViewController.swift
//  FaceReader
//
//  Created by COBY_PRO on 2022/08/22.
//

import UIKit

import AVFoundation
import Vision

class FaceDetectionViewController: BaseViewController {
    var sequenceHandler = VNSequenceRequestHandler()
    
    private lazy var cameraButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTapCameraButton), for: .touchUpInside)
        button.setImage(ImageLiterals.btnCamera, for: .normal)
        return button
    }()
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let session = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    let dataOutputQueue = DispatchQueue(
        label: "video data queue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCaptureSession()
        
        session.startRunning()
    }
    
    override func render() {
        view.addSubviews(backgroundView, cameraButton)
        
        let backgroundViewConstraints = [
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.heightAnchor.constraint(equalToConstant: 120),
        ]

        let cameraButtonConstraints = [
            cameraButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            cameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cameraButton.heightAnchor.constraint(equalToConstant: 50),
            cameraButton.widthAnchor.constraint(equalToConstant: 50)
        ]

        [backgroundViewConstraints, cameraButtonConstraints].forEach { constraints in
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()

        navigationItem.leftBarButtonItem = nil
        title = "얼굴 사진을 찍어주세요"
    }
    
    @objc private func didTapCameraButton() {
        guard (FaceManager.leftEye != nil) else { return }
        
        FaceManager.shared.postImage() { result in
            switch result {
            case .success(let image):
                print(image)
                FaceManager.cartoonImage = image
                FaceManager.shared.setValues()
                self.navigationController?.pushViewController(FaceResultViewController(), animated: true)
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: - Video Processing methods

extension FaceDetectionViewController {
    func configureCaptureSession() {
        // Define the capture device we want to use
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .front) else {
            fatalError("No front video camera available")
        }
        
        // Connect the camera to the capture session input
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            session.addInput(cameraInput)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        // Create the video data output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        // Add the video output to the capture session
        session.addOutput(videoOutput)
        
        let videoConnection = videoOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait
        
        // Configure the preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate methods

extension FaceDetectionViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // 1
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let ciimage = CIImage(cvPixelBuffer: imageBuffer)
        FaceManager.faceImage = self.convert(cmage: ciimage)
        
        // 2
        let detectFaceRequest = VNDetectFaceLandmarksRequest(completionHandler: detectedFace)
        
        // 3
        do {
            try sequenceHandler.perform(
                [detectFaceRequest],
                on: imageBuffer,
                orientation: .leftMirrored)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func convert(cmage: CIImage) -> UIImage {
         let context = CIContext(options: nil)
         let cgImage = context.createCGImage(cmage, from: cmage.extent)!
         let image = UIImage(cgImage: cgImage)
         return image
    }
}

extension FaceDetectionViewController {
    func convert(rect: CGRect) -> CGRect {
        // 1
        let origin = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.origin)
        
        // 2
        let size = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.size.cgPoint)
        
        // 3
        return CGRect(origin: origin, size: size.cgSize)
    }
    
    // 1
    func landmark(point: CGPoint, to rect: CGRect) -> CGPoint {
        // 2
        let absolute = point.absolutePoint(in: rect)
        
        // 3
        let converted = previewLayer.layerPointConverted(fromCaptureDevicePoint: absolute)
        
        // 4
        return converted
    }
    
    func landmark(points: [CGPoint]?, to rect: CGRect) -> [CGPoint]? {
        guard let points = points else {
            return nil
        }
        
        return points.compactMap { landmark(point: $0, to: rect) }
    }
    
    func updateFaceView(for result: VNFaceObservation) {
        guard let landmarks = result.landmarks else {
            return
        }

        if let leftEye = landmark(
            points: landmarks.leftEye?.normalizedPoints,
            to: result.boundingBox) {
            FaceManager.leftEye = leftEye
        }

        if let rightEye = landmark(
            points: landmarks.rightEye?.normalizedPoints,
            to: result.boundingBox) {
            FaceManager.rightEye = rightEye
        }

        if let leftEyebrow = landmark(
            points: landmarks.leftEyebrow?.normalizedPoints,
            to: result.boundingBox) {
            FaceManager.leftEyebrow = leftEyebrow
        }

        if let rightEyebrow = landmark(
            points: landmarks.rightEyebrow?.normalizedPoints,
            to: result.boundingBox) {
            FaceManager.rightEyebrow = rightEyebrow
        }

        if let nose = landmark(
            points: landmarks.nose?.normalizedPoints,
            to: result.boundingBox) {
            FaceManager.nose = nose
        }

        if let outerLips = landmark(
            points: landmarks.outerLips?.normalizedPoints,
            to: result.boundingBox) {
            FaceManager.outerLips = outerLips
        }

        if let innerLips = landmark(
            points: landmarks.innerLips?.normalizedPoints,
            to: result.boundingBox) {
            FaceManager.innerLips = innerLips
        }

        if let faceContour = landmark(
            points: landmarks.faceContour?.normalizedPoints,
            to: result.boundingBox) {
            FaceManager.faceContour = faceContour
        }
    }
    
    func detectedFace(request: VNRequest, error: Error?) {
        guard
            let results = request.results as? [VNFaceObservation],
            let result = results.first
        else { return }
        
        updateFaceView(for: result)
    }
}
