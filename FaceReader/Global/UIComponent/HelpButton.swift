//
//  HelpButton.swift
//  FaceReader
//
//  Created by COBY_PRO on 2023/04/29.
//

import UIKit

final class HelpButton: UIButton {

    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: .init(origin: .zero, size: .init(width: 44, height: 44)))
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        self.setImage(ImageLiterals.btnHelp.resize(to: CGSize(width: 30, height: 30)), for: .normal)
    }
}
