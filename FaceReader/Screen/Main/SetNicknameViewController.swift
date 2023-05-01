//
//  SetNicknameViewController.swift
//  FaceReader
//
//  Created by COBY_PRO on 2023/05/01.
//

import UIKit

final class SetNicknameViewController: BaseViewController {
    private let guideLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(.regular, ofSize: 22)
        label.textColor = .mainText
        label.text = "닉네임 설정"
        return label
    }()
    
    private lazy var nicknameField: UITextField = {
        let textField = UITextField()
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.mainText.withAlphaComponent(0.5),
            NSAttributedString.Key.font: UIFont.font(.regular, ofSize: 20)
        ]

        textField.backgroundColor = .clear
        textField.attributedPlaceholder = NSAttributedString(
            string: "사용할 괴인 닉네임을 등록해주세요.",
            attributes: attributes
        )
        textField.autocapitalizationType = .none
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        textField.clipsToBounds = false
        textField.clearButtonMode = .always
        textField.makeBorderLayer(color: .mainText.withAlphaComponent(0.5))
        textField.delegate = self
        textField.font = UIFont.font(.regular, ofSize: 20)
        return textField
    }()
    
    private lazy var completeButton: UIButton = {
        let button = MainButton()
        button.label.text = "완료"
        let action = UIAction { [weak self] _ in
            self?.backToMainViewController()
        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let nickname = UserDefaults.standard.string(forKey: "nickname") else { return }
        nicknameField.text = nickname
    }
    
    override func setupLayout() {
        view.addSubviews(guideLabel, nicknameField, completeButton)

        let guideLabelConstraints = [
            guideLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            guideLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ]

        let nicknameFieldConstraints = [
            nicknameField.topAnchor.constraint(equalTo: guideLabel.bottomAnchor, constant: 20),
            nicknameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nicknameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nicknameField.heightAnchor.constraint(equalToConstant: 60)
        ]
        
        let completeButtonConstraints = [
            completeButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -10),
            completeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            completeButton.heightAnchor.constraint(equalToConstant: 60)
        ]
        
        [
            guideLabelConstraints,
            nicknameFieldConstraints,
            completeButtonConstraints
        ].forEach { constraints in
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    private func backToMainViewController() {
        guard let nickname = nicknameField.text,
        nicknameField.text?.count != 0 else {
            showToast()
            return
        }
        
        UserDefaults.standard.set(nickname, forKey: "nickname")
        dismiss(animated: true, completion: nil)
    }
    
    private func showToast() {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height - 80, width: 150, height: 35))
        toastLabel.backgroundColor = .mainText.withAlphaComponent(0.6)
        toastLabel.textColor = .mainBackground
        toastLabel.font = .font(.regular, ofSize: 20)
        toastLabel.textAlignment = .center;
        toastLabel.text = "닉네임을 다시 입력해주세요"
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
}
