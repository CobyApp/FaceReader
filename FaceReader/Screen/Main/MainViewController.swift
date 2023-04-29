//
//  MainViewController.swift
//  FaceReader
//
//  Created by COBY_PRO on 2023/04/28.
//

import UIKit

import FirebaseFirestore

final class MainViewController: BaseViewController {
    private var monsters = [Monster]()
    private var cursor: DocumentSnapshot?
    private var dataMayContinue = true
    private var pages = 3
    
    private enum Size {
        static let collectionHorizontalSpacing: CGFloat = 20.0
        static let collectionVerticalSpacing: CGFloat = 4.0
        static let cellWidth: CGFloat = UIScreen.main.bounds.size.width - collectionHorizontalSpacing * 2
        static let cellHeight: CGFloat = 60
        static let collectionInset = UIEdgeInsets(
            top: collectionVerticalSpacing,
            left: collectionHorizontalSpacing,
            bottom: collectionVerticalSpacing,
            right: collectionHorizontalSpacing
        )
    }
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.logo.resize(to: CGSize(width: 30, height: 30))
        return imageView
    }()
    
    private lazy var helpButton: HelpButton = {
        let button = HelpButton()
        let action = UIAction { [weak self] _ in
            self?.navigationController?.pushViewController(HelpViewController(), animated: true)
        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()
    
    private lazy var cameraButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setImage(
            ImageLiterals.btnCamera.resize(to: CGSize(width: 30, height: 30)).withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        button.tintColor = .white
        button.layer.cornerRadius = 30
        let action = UIAction { [weak self] _ in
            self?.navigationController?.pushViewController(FaceDetectionViewController(), animated: true)
        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()
    
    private lazy var segControl: MSegmentedControl = {
        let segControl = MSegmentedControl(
            frame: CGRect(x: 0, y: 0, width: 0, height: 0),
            buttonTitle: ["일간", "주간", "월간", "올타임"])
        segControl.textColor = .black
        segControl.selectorTextColor = .white
        segControl.delegate = self
        return segControl
    }()
    
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
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(
            cell: RankCollectionViewCell.self,
            forCellWithReuseIdentifier: RankCollectionViewCell.className
        )
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    override func setupLayout() {
        view.addSubviews(segControl, listCollectionView, cameraButton)
        
        let segControlConstraints = [
            segControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            segControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),
            segControl.heightAnchor.constraint(equalToConstant: 44)
        ]
        
        let listCollectionViewConstraints = [
            listCollectionView.topAnchor.constraint(equalTo: segControl.bottomAnchor, constant: 10),
            listCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            listCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        
        let cameraButtonConstraints = [
            cameraButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cameraButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            cameraButton.widthAnchor.constraint(equalToConstant: 70),
            cameraButton.heightAnchor.constraint(equalToConstant: 70)
        ]
        
        [segControlConstraints, listCollectionViewConstraints, cameraButtonConstraints]
            .forEach { constraints in
                NSLayoutConstraint.activate(constraints)
            }
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        title = "LEADER BOARD"
        let logoImageView = makeBarButtonItem(with: logoImageView)
        let helpButton = makeBarButtonItem(with: helpButton)
        navigationItem.leftBarButtonItem = logoImageView
        navigationItem.rightBarButtonItem = helpButton
    }
    
    private func loadData() {
        Task {
            if let result = await FirebaseManager.shared.loadMonsters(term: "", pages: pages) {
                self.monsters = result.monsters
                self.cursor = result.cursor
            }
            
            DispatchQueue.main.async {
                self.listCollectionView.reloadData()
            }
        }
    }
    
    private func continueData() {
        guard dataMayContinue, let cursor = cursor else { return }
        dataMayContinue = false
        
        Task {
            if let result = await FirebaseManager.shared.continueMonsters(term: "", cursor: cursor, pages: pages) {
                self.monsters = result.monsters
                self.cursor = result.cursor
            }
            
            DispatchQueue.main.async {
                self.listCollectionView.reloadData()
            }
            
            self.dataMayContinue = true
        }
    }
}

// MARK: - UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return monsters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: RankCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)

        cell.rankLabel.text = "\(indexPath.item + 1)"
        cell.nicknameLabel.text = monsters[indexPath.item].nickname
        cell.gradeLabel.text = gradeData[monsters[indexPath.item].grade]["grade"]! as? String
        cell.moneyLabel.text = "\(monsters[indexPath.item].score)"
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let viewController = MeetingDetailViewController(meeting: meetings[indexPath.item])
//        DispatchQueue.main.async {
//            self.navigationController?.pushViewController(viewController, animated: true)
//        }
    }
}

extension MainViewController: MSegmentedControlDelegate {
    func segSelectedIndexChange(to index: Int) {
        switch index {
        case 0: print("일간")
        case 1: print("주간")
        case 2: print("월간")
        case 3: print("올타임")
        default: break
        }
    }
}

extension MainViewController {
    /* Standard scroll-view delegate */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentSize = scrollView.contentSize.height
        
        if contentSize - scrollView.contentOffset.y <= scrollView.bounds.height {
            didScrollToBottom()
        }
    }
    
    private func didScrollToBottom() {
        continueData()
    }
}
