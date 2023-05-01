//
//  GradeInfoCollectionViewCell.swift
//  FaceReader
//
//  Created by COBY_PRO on 2023/04/29.
//

import UIKit

final class GradeInfoCollectionViewCell: BaseCollectionViewCell {
    private enum Size {
        static let imageWidth: CGFloat = UIScreen.main.bounds.size.width - 40
        static let imageHeight: CGFloat = imageWidth * 0.562
    }
    
    // MARK: - property
    let gradeImageView = UIImageView()

    let gradeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(.regular, ofSize: 22)
        label.textColor = .mainText
        return label
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(.regular, ofSize: 17)
        label.numberOfLines = 0
        label.textColor = .mainText
        return label
    }()

    override func setupLayout() {
        contentView.addSubviews(gradeImageView, gradeLabel, detailLabel)

        let gradeImageViewConstraints = [
            gradeImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            gradeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gradeImageView.heightAnchor.constraint(equalToConstant: Size.imageHeight)
        ]
        
        let gradeLabelConstraints = [
            gradeLabel.topAnchor.constraint(equalTo: gradeImageView.bottomAnchor, constant: 10),
            gradeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ]
        
        let detailLabelConstraints = [
            detailLabel.topAnchor.constraint(equalTo: gradeLabel.bottomAnchor, constant: 4),
            detailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ]

        [
            gradeImageViewConstraints,
            gradeLabelConstraints,
            detailLabelConstraints
        ]
        .forEach { constraints in
            NSLayoutConstraint.activate(constraints)
        }
    }
}
