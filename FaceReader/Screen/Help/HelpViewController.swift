//
//  HelpViewController.swift
//  FaceReader
//
//  Created by COBY_PRO on 2023/04/29.
//

import UIKit

final class HelpViewController: BaseViewController {
    private enum Size {
        static let collectionHorizontalSpacing: CGFloat = 20.0
        static let collectionVerticalSpacing: CGFloat = 0.0
        static let cellWidth: CGFloat = UIScreen.main.bounds.size.width - collectionHorizontalSpacing * 2
        static let cellHeight: CGFloat = 400
        static let collectionInset = UIEdgeInsets(
            top: collectionVerticalSpacing,
            left: collectionHorizontalSpacing,
            bottom: collectionVerticalSpacing,
            right: collectionHorizontalSpacing
        )
    }
    
    private let collectionViewFlowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = Size.collectionInset
        flowLayout.itemSize = CGSize(width: Size.cellWidth, height: Size.cellHeight)
        flowLayout.minimumLineSpacing = 10
        return flowLayout
    }()

    private lazy var listCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(
            cell: GradeInfoCollectionViewCell.self,
            forCellWithReuseIdentifier: GradeInfoCollectionViewCell.className
        )
        return collectionView
    }()
    
    override func setupLayout() {
        view.addSubviews(listCollectionView)
        
        let listCollectionViewConstraints = [
            listCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            listCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            listCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        
        [listCollectionViewConstraints]
            .forEach { constraints in
                NSLayoutConstraint.activate(constraints)
            }
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        title = "재해 레벨"
    }
}

// MARK: - UICollectionViewDataSource
extension HelpViewController: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GradeInfoCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        
        cell.gradeImageView.image = gradeData[indexPath.item]["image"] as? UIImage
        cell.gradeLabel.text = "\(gradeData[indexPath.item]["grade"]!) : \(gradeData[indexPath.item]["info"]!)"
        cell.detailLabel.text = gradeData[indexPath.item]["detail"] as? String

        return cell
    }
}
