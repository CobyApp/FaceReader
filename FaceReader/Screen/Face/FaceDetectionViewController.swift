//
//  MainViewController.swift
//  FaceReader
//
//  Created by COBY_PRO on 2022/08/22.
//

import UIKit

import AVFoundation
import Lottie
import Vision

final class FaceDetectionViewController: BaseViewController {
    
    private enum Size {
        static let topBackgroundHeight: CGFloat = UIScreen.main.bounds.size.height * 0.18
        static let backgroundHeight: CGFloat = UIScreen.main.bounds.size.height * 0.3
    }
    
    var sequenceHandler = VNSequenceRequestHandler()
    
    private let loading: AnimationView = .init(name: "loading")
    
    private let coverView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainText.withAlphaComponent(0.5)
        return view
    }()
    
    private let topBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainBackground.withAlphaComponent(0.7)
        return view
    }()
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainBackground.withAlphaComponent(0.7)
        return view
    }()
    
    private let ratioGuideLabel: UILabel = {
        let label = UILabel()
        label.text = "얼굴 비율로 괴인 등급을 측정합니다."
        label.textColor = .mainText
        label.font = .font(.regular, ofSize: 24)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let tipLabel: UILabel = {
        let label = UILabel()
        label.text = """
눈, 코, 입, 얼굴형 등의 좌표값을 통해 비율을 측정하므로
얼굴을 망가뜨릴수록 높은 등급을 얻을 수 있습니다.
"""
        label.textColor = .mainText
        label.font = .font(.regular, ofSize: 17)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        return label
    }()
    
    private let photoGuideLabel: UILabel = {
        let label = UILabel()
        label.text = "얼굴 사진은 카툰화 이미지로 변경됩니다."
        label.textColor = .mainText
        label.font = .font(.regular, ofSize: 24)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var cameraButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTapCameraButton), for: .touchUpInside)
        button.setImage(ImageLiterals.btnCamera, for: .normal)
        return button
    }()
    
    private lazy var editButton: EditButton = {
        let button = EditButton()
        let action = UIAction { [weak self] _ in
            self?.setNickname()
        }
        button.addAction(action, for: .touchUpInside)
        return button
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
    
    override func setupLayout() {
        view.addSubviews(topBackgroundView, backgroundView, ratioGuideLabel, tipLabel, photoGuideLabel, cameraButton, coverView, loading)
        loading.isHidden = true
        coverView.isHidden = true
        
        let topBackgroundViewConstraints = [
            topBackgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBackgroundView.heightAnchor.constraint(equalToConstant: Size.topBackgroundHeight),
        ]
        
        let backgroundViewConstraints = [
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.heightAnchor.constraint(equalToConstant: Size.backgroundHeight),
        ]
        
        let ratioGuideLabelConstraints = [
            ratioGuideLabel.bottomAnchor.constraint(equalTo: topBackgroundView.topAnchor, constant: 66),
            ratioGuideLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            ratioGuideLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ]
        
        let tipLabelConstraints = [
            tipLabel.bottomAnchor.constraint(equalTo: ratioGuideLabel.bottomAnchor, constant: 50),
            tipLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tipLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ]
        
        let photoGuideLabelConstraints = [
            photoGuideLabel.bottomAnchor.constraint(equalTo: cameraButton.topAnchor, constant: -40),
            photoGuideLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            photoGuideLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ]

        let cameraButtonConstraints = [
            cameraButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80),
            cameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cameraButton.heightAnchor.constraint(equalToConstant: 50),
            cameraButton.widthAnchor.constraint(equalToConstant: 50)
        ]
        
        let coverViewConstraints = [
            coverView.topAnchor.constraint(equalTo: view.topAnchor),
            coverView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            coverView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            coverView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        
        let loadingConstraints = [
            loading.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loading.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]

        [topBackgroundViewConstraints, backgroundViewConstraints, ratioGuideLabelConstraints, tipLabelConstraints, photoGuideLabelConstraints, cameraButtonConstraints, coverViewConstraints, loadingConstraints].forEach { constraints in
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        title = "괴인 측정기"
        let editButton = makeBarButtonItem(with: editButton)
        navigationItem.rightBarButtonItem = editButton
    }
    
    @objc private func didTapCameraButton() {
        guard (FaceManager.leftEye != nil) else {
            showToast()
            return
        }
        coverView.isHidden = false
        loading.isHidden = false
        loading.play()
        
        FaceManager.shared.postImage() { result in
            switch result {
            case .success(let image):
                FaceManager.cartoonImage = image
                FaceManager.shared.setValues()
                self.loading.pause()
                self.loading.isHidden = true
                self.coverView.isHidden = true
                self.navigationController?.pushViewController(FaceResultViewController(), animated: true)
            case .failure(_):
                FaceManager.cartoonImage = FaceManager.faceImage
                FaceManager.shared.setValues()
                self.loading.pause()
                self.loading.isHidden = true
                self.coverView.isHidden = true
                self.navigationController?.pushViewController(FaceResultViewController(), animated: true)
            }
        }
    }
    
    private func showToast() {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height - 80, width: 150, height: 35))
        toastLabel.backgroundColor = .mainText.withAlphaComponent(0.6)
        toastLabel.textColor = .mainBackground
        toastLabel.font = .font(.regular, ofSize: 20)
        toastLabel.textAlignment = .center;
        toastLabel.text = "얼굴을 촬영해주세요"
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    private func setNickname() {
        let vc = SetNicknameViewController()
        vc.modalPresentationStyle = .pageSheet
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        
        present(vc, animated: true, completion: nil)
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
