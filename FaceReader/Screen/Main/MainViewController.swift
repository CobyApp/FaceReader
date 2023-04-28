//
//  MainViewController.swift
//  FaceReader
//
//  Created by COBY_PRO on 2023/04/28.
//

import UIKit

final class MainViewController: BaseViewController {
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.logo.resize(to: CGSize(width: 34, height: 34))
        return imageView
    }()
    
    private lazy var cameraButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setImage(
            ImageLiterals.btnCamera.resize(to: CGSize(width: 30, height: 30)).withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        button.tintColor = .white
        button.layer.cornerRadius = 30
        let action = UIAction { [weak self] _ in
            self?.navigationController?.pushViewController(FaceDetectionViewController(), animated: true)
        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()
    
    override func setupLayout() {
        view.addSubviews(cameraButton)
        
        let cameraButtonConstraints = [
            cameraButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cameraButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            cameraButton.widthAnchor.constraint(equalToConstant: 70),
            cameraButton.heightAnchor.constraint(equalToConstant: 70)
        ]
        
        [cameraButtonConstraints]
            .forEach { constraints in
                NSLayoutConstraint.activate(constraints)
            }
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        title = "괴인 측정기"
        let logoImageView = makeBarButtonItem(with: logoImageView)
        navigationItem.leftBarButtonItem = logoImageView
    }
}
