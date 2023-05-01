//
//  EditButton.swift
//  FaceReader
//
//  Created by COBY_PRO on 2023/05/02.
//

import UIKit

final class EditButton: UIButton {

    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: .init(origin: .zero, size: .init(width: 30, height: 30)))
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        setImage(ImageLiterals.btnEdit.resize(to: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysTemplate), for: .normal)
        tintColor = .mainText
    }
}
