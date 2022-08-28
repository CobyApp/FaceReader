//
//  FaceResultViewController.swift
//  FaceReader
//
//  Created by COBY_PRO on 2022/08/23.
//

import UIKit

class FaceResultViewController: BaseViewController {
    
    private enum Size {
        static let imageWidth: CGFloat = UIScreen.main.bounds.size.width - 40
        static let imageHeight: CGFloat = imageWidth * 0.8
    }
    
    private lazy var backLabel: UILabel = {
        let label = UILabel()
        label.text = "다시 찍기"
        label.font = .font(.regular, ofSize: 20)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBackLabel))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
        return label
    }()
    
    private lazy var shareLabel: UILabel = {
        let label = UILabel()
        label.text = "공유"
        label.font = .font(.regular, ofSize: 20)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapShareLabel))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
        return label
    }()
    
    private let scrollView : UIScrollView! = UIScrollView()
    private let contentView : UIView! = UIView()
    
    private let wantedLabel: UILabel = {
        let label = UILabel()
        label.text = "WANTED"
        label.font = .font(.regular, ofSize: 80)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let faceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = FaceManager.cartoonImage
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 5
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.cornerRadius = 5
        return imageView
    }()
    
    private lazy var gradeLabel: UILabel = {
        let label = UILabel()
        label.text = "\(gradeData[FaceManager.grade]["grade"]!) \(gradeData[FaceManager.grade]["info"]!)"
        label.font = .font(.regular, ofSize: 40)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.text = "현상금 : \(numberFormatter(number: FaceManager.totalScore*100))원"
        label.font = .font(.regular, ofSize: 30)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override func render() {
        view.addSubviews(scrollView)
        scrollView.addSubviews(contentView)
        contentView.addSubviews(wantedLabel, faceImageView, gradeLabel, scoreLabel)
        contentView.backgroundColor = UIColor(patternImage: ImageLiterals.background)
        
        let contentViewHeight = contentView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor)
        contentViewHeight.priority = .defaultLow
        contentViewHeight.isActive = true
        
        scrollView.showsVerticalScrollIndicator = false
        
        let scrollViewConstraints = [
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        
        let contentViewConstraints = [
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ]
        
        let wantedLabelConstraints = [
            wantedLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            wantedLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            wantedLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
        ]
        
        let faceImageViewConstraints = [
            faceImageView.topAnchor.constraint(equalTo: wantedLabel.bottomAnchor, constant: 8),
            faceImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            faceImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            faceImageView.heightAnchor.constraint(equalToConstant: Size.imageHeight)
        ]
        
        let gradeLabelConstraints = [
            gradeLabel.topAnchor.constraint(equalTo: faceImageView.bottomAnchor, constant: 20),
            gradeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            gradeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ]
        
        let scoreLabelConstraints = [
            scoreLabel.topAnchor.constraint(equalTo: gradeLabel.bottomAnchor, constant: 20),
            scoreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            scoreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ]
        
        [scrollViewConstraints, contentViewConstraints, wantedLabelConstraints, faceImageViewConstraints, gradeLabelConstraints, scoreLabelConstraints].forEach { constraints in
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        
        let backLabelView = makeBarButtonItem(with: backLabel)
        let shareLabelView = makeBarButtonItem(with: shareLabel)

        navigationItem.leftBarButtonItem = backLabelView
        navigationItem.rightBarButtonItem = shareLabelView
        title = "괴인 측정 결과"
    }
    
    func numberFormatter(number: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter.string(from: NSNumber(value: number))!
    }
    
    @objc private func didTapBackLabel(sender: UITapGestureRecognizer) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapShareLabel(sender: UITapGestureRecognizer) {
        let wantedImage = contentView.asImage()
        var shareObject = [UIImage]()
        
        shareObject.append(wantedImage)
        
        let activityViewController = UIActivityViewController(activityItems : shareObject, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        

        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToFacebook,
            UIActivity.ActivityType.postToTwitter,
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.copyToPasteboard,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.openInIBooks,
            UIActivity.ActivityType.markupAsPDF
        ]

        self.present(activityViewController, animated: true)
    }
}
