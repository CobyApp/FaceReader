//
//  EmptyRankView.swift
//  FaceReader
//
//  Created by COBY_PRO on 2023/04/30.
//

import UIKit

final class EmptyRankView: UIView {
    // MARK: - Property
    private let guideEmptyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(.regular, ofSize: 22)
        label.textColor = .black
        label.text = "등록된 괴인이 없습니다."
        return label
    }()

    // MARK: - init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - func

    private func setupLayout() {
        addSubviews(guideEmptyLabel)

        let guideEmptyLabelConstraints = [
            guideEmptyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            guideEmptyLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10)
        ]

        [guideEmptyLabelConstraints].forEach { constraints in
            NSLayoutConstraint.activate(constraints)
        }
    }
}
