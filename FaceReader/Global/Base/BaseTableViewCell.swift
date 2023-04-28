//
//  BaseTableViewCell.swift
//  FaceReader
//
//  Created by COBY_PRO on 2023/04/28.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    // MARK: - init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - func

    func setupLayout() {
        // Override Layout
    }

    func configureUI() {
        // Override ConfigUI
    }
}
