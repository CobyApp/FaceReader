//
//  MainButton.swift
//  FaceReader
//
//  Created by COBY_PRO on 2023/05/02.
//

import UIKit

final class MainButton: UIButton {
    // MARK: - property

    let label: UILabel = {
        let label = UILabel()
        label.font = .font(.regular, ofSize: 22)
        label.textColor = .mainBackground
        return label
    }()

    // MARK: - init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - func

    private func setupLayout() {
        addSubviews(label)

        let labelConstraints = [
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]

        [labelConstraints].forEach { constraints in
            NSLayoutConstraint.activate(constraints)
        }
    }

    private func configureUI() {
        backgroundColor = .mainText
        layer.cornerRadius = 30
        layer.masksToBounds = false
    }
}
