//
//  RankCollectionViewCell.swift
//  FaceReader
//
//  Created by COBY_PRO on 2023/04/29.
//

import UIKit

final class RankCollectionViewCell: BaseCollectionViewCell {
    // MARK: - property
    let rankLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(.regular, ofSize: 22)
        label.textColor = .mainText
        return label
    }()

    let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(.regular, ofSize: 22)
        label.textColor = .mainText
        return label
    }()
    
    let gradeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(.regular, ofSize: 22)
        label.textColor = .mainText
        return label
    }()
    
    let moneyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(.regular, ofSize: 22)
        label.textColor = .mainText
        return label
    }()

    override func setupLayout() {
        contentView.addSubviews(rankLabel, nicknameLabel, gradeLabel, moneyLabel)

        let rankLabelConstraints = [
            rankLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rankLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            rankLabel.widthAnchor.constraint(equalToConstant: 50)
        ]
        
        let nicknameLabelConstraints = [
            nicknameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nicknameLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 20)
        ]
        
        let gradeLabelConstraints = [
            gradeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            gradeLabel.leadingAnchor.constraint(equalTo: nicknameLabel.trailingAnchor, constant: 20)
        ]
        
        let moneyLabelConstraints = [
            moneyLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            moneyLabel.leadingAnchor.constraint(equalTo: gradeLabel.trailingAnchor, constant: 20)
        ]


        [
            rankLabelConstraints,
            nicknameLabelConstraints,
            gradeLabelConstraints,
            moneyLabelConstraints
        ]
        .forEach { constraints in
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    override func configureUI() {
        makeBorderLayer(color: .black.withAlphaComponent(0.5))
    }
}
