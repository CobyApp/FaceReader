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
        static let imageHeight: CGFloat = imageWidth * 1.2
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
    
    private let faceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = FaceManager.faceImage
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var gradeLabel: UILabel = {
        let label = UILabel()
        label.text = "재해레벨 : \(gradeData[FaceManager.grade]["grade"]!)"
        label.font = .font(.regular, ofSize: 24)
        return label
    }()
    
    private lazy var gradeInfoLabel: UILabel = {
        let label = UILabel()
        label.text = gradeData[FaceManager.grade]["info"]
        label.font = .font(.regular, ofSize: 20)
        return label
    }()
    
    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.text = "현상금 : \(numberFormatter(number: FaceManager.totalScore*100))원"
        label.font = .font(.regular, ofSize: 20)
        return label
    }()
    
    private lazy var levelLabel: UILabel = {
        let label = UILabel()
        label.text = "낭(狼) > 호(虎) > 귀(鬼) > 용(龍) > 신(神)"
        label.font = .font(.regular, ofSize: 14)
        return label
    }()
    
    override func render() {
        view.addSubviews(scrollView)
        scrollView.addSubviews(contentView)
        contentView.addSubviews(faceImageView, gradeLabel, gradeInfoLabel, scoreLabel, levelLabel)
        
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
        
        let faceImageViewConstraints = [
            faceImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            faceImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            faceImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            faceImageView.heightAnchor.constraint(equalToConstant: Size.imageHeight)
        ]
        
        let gradeLabelConstraints = [
            gradeLabel.topAnchor.constraint(equalTo: faceImageView.bottomAnchor, constant: 20),
            gradeLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ]
        
        let gradeInfoLabelConstraints = [
            gradeInfoLabel.topAnchor.constraint(equalTo: gradeLabel.bottomAnchor, constant: 20),
            gradeInfoLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ]
        
        let scoreLabelConstraints = [
            scoreLabel.topAnchor.constraint(equalTo: gradeInfoLabel.bottomAnchor, constant: 20),
            scoreLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ]
        
        let levelLabelConstraints = [
            levelLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 20),
            levelLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ]
        
        [scrollViewConstraints, contentViewConstraints, faceImageViewConstraints, gradeLabelConstraints, gradeInfoLabelConstraints, scoreLabelConstraints, levelLabelConstraints].forEach { constraints in
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
    }
}
