//
//  RankCollectionViewCell.swift
//  FaceReader
//
//  Created by COBY_PRO on 2023/04/29.
//

import UIKit

final class RankCollectionViewCell: BaseCollectionViewCell {
    private enum Size {
        static let screenWidth: CGFloat = UIScreen.main.bounds.size.width - 80
        static let rankWidth: CGFloat = screenWidth * 0.1
        static let gradeWidth: CGFloat = screenWidth * 0.2
        static let nicknameWidth: CGFloat = screenWidth * 0.4
        static let moneyWidth: CGFloat = screenWidth * 0.3
    }
    // MARK: - property
    let rankLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(.regular, ofSize: 20)
        label.textColor = .mainText
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let gradeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(.regular, ofSize: 20)
        label.textColor = .mainText
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(.regular, ofSize: 20)
        label.textColor = .mainText
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let moneyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(.regular, ofSize: 20)
        label.textColor = .mainText
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    override func setupLayout() {
        contentView.addSubviews(rankLabel, gradeLabel, nicknameLabel, moneyLabel)

        let rankLabelConstraints = [
            rankLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rankLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            rankLabel.widthAnchor.constraint(equalToConstant: Size.rankWidth)
        ]
        
        let gradeLabelConstraints = [
            gradeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            gradeLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor),
            gradeLabel.widthAnchor.constraint(equalToConstant: Size.gradeWidth)
        ]
        
        let nicknameLabelConstraints = [
            nicknameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nicknameLabel.leadingAnchor.constraint(equalTo: gradeLabel.trailingAnchor),
            nicknameLabel.widthAnchor.constraint(equalToConstant: Size.nicknameWidth)
        ]
        
        let moneyLabelConstraints = [
            moneyLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            moneyLabel.leadingAnchor.constraint(equalTo: nicknameLabel.trailingAnchor),
            moneyLabel.widthAnchor.constraint(equalToConstant: Size.moneyWidth)
        ]


        [
            rankLabelConstraints,
            gradeLabelConstraints,
            nicknameLabelConstraints,
            moneyLabelConstraints
        ]
        .forEach { constraints in
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    override func configureUI() {
        makeBorderLayer(color: .mainText.withAlphaComponent(0.5))
    }
}
