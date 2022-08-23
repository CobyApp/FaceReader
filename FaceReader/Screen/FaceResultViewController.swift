//
//  FaceResultViewController.swift
//  FaceReader
//
//  Created by COBY_PRO on 2022/08/23.
//

import UIKit

class FaceResultViewController: BaseViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "괴인 측정기"
        label.font = .systemFont(ofSize: 30, weight: .semibold)
        return label
    }()
    
    private let faceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.btnCamera
        return imageView
    }()
    
    private lazy var gradeLabel: UILabel = {
        let label = UILabel()
        label.text = "괴인 등급 : 용"
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        return label
    }()
    
    private lazy var gradeInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "설명입니다"
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    override func render() {
        view.addSubviews(titleLabel, faceImageView, gradeLabel, gradeInfoLabel)
        
        let titleLabelConstraints = [
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        let faceImageViewConstraints = [
            faceImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            faceImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            faceImageView.widthAnchor.constraint(equalToConstant: 80),
            faceImageView.heightAnchor.constraint(equalToConstant: 80)
        ]
        
        let gradeLabelConstraints = [
            gradeLabel.topAnchor.constraint(equalTo: faceImageView.bottomAnchor, constant: 20),
            gradeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        let gradeInfoLabelConstraints = [
            gradeInfoLabel.topAnchor.constraint(equalTo: gradeLabel.bottomAnchor, constant: 20),
            gradeInfoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        [titleLabelConstraints, faceImageViewConstraints, gradeLabelConstraints, gradeInfoLabelConstraints].forEach { constraints in
            NSLayoutConstraint.activate(constraints)
        }
    }
}
