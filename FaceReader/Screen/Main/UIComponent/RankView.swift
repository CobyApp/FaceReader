//
//  RankView.swift
//  FaceReader
//
//  Created by COBY_PRO on 2023/04/28.
//

import UIKit

final class RankView: UIView {
    // MARK: - Property

    private let rankLabel: UILabel = {
        let label = UILabel()
        label.font = .font(.regular, ofSize: 14)
        label.text = "1"
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
    }
}
