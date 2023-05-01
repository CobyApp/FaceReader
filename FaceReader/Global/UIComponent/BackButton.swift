//
//  BackButton.swift
//  FaceReader
//
//  Created by COBY_PRO on 2022/08/23.
//

import UIKit

final class BackButton: UIButton {

    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: .init(origin: .zero, size: .init(width: 44, height: 44)))
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        setImage(ImageLiterals.btnBack, for: .normal)
        tintColor = .mainText
    }
}
