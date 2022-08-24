//
//  FaceResultViewController.swift
//  FaceReader
//
//  Created by COBY_PRO on 2022/08/23.
//

import UIKit

class FaceResultViewController: BaseViewController {
    
    private let faceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = FaceManager.faceImage
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var gradeLabel: UILabel = {
        let label = UILabel()
        label.text = "재해레벨 : \(gradeData[FaceManager.grade]["grade"]!)"
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        return label
    }()
    
    private lazy var gradeInfoLabel: UILabel = {
        let label = UILabel()
        label.text = gradeData[FaceManager.grade]["info"]
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    override func render() {
        view.addSubviews(faceImageView, gradeLabel, gradeInfoLabel)
        
        let faceImageViewConstraints = [
            faceImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            faceImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            faceImageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width - 40),
            faceImageView.heightAnchor.constraint(equalToConstant: 200)
        ]
        
        let gradeLabelConstraints = [
            gradeLabel.topAnchor.constraint(equalTo: faceImageView.bottomAnchor, constant: 20),
            gradeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        let gradeInfoLabelConstraints = [
            gradeInfoLabel.topAnchor.constraint(equalTo: gradeLabel.bottomAnchor, constant: 20),
            gradeInfoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        [faceImageViewConstraints, gradeLabelConstraints, gradeInfoLabelConstraints].forEach { constraints in
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()

        navigationItem.leftBarButtonItem = nil
        title = "괴인 측정 결과"
    }
}
