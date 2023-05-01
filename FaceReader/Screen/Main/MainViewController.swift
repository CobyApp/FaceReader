//
//  MainViewController.swift
//  FaceReader
//
//  Created by COBY_PRO on 2023/04/28.
//

import UIKit

import FirebaseFirestore

final class MainViewController: BaseViewController {
    private var term: Int = 0
    private var monsters = [Monster]()
    private var cursor: DocumentSnapshot?
    private var dataMayContinue = true
    private var pages = 50
    private var refreshControl = UIRefreshControl()
    
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
        imageView.image = ImageLiterals.logo.resize(to: CGSize(width: 30, height: 30)).withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .mainText
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
        button.backgroundColor = .mainText
        button.setImage(
            ImageLiterals.btnCamera.resize(to: CGSize(width: 30, height: 30)).withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        button.tintColor = .mainBackground
        button.layer.cornerRadius = 30
        let action = UIAction { [weak self] _ in
            self?.moveToCamera()
        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()
    
    private lazy var segControl: MSegmentedControl = {
        let segControl = MSegmentedControl(
            frame: CGRect(x: 0, y: 0, width: 0, height: 0),
            buttonTitle: ["일간", "월간", "연간", "올타임"])
        segControl.textColor = .mainText
        segControl.selectorViewColor = .mainText
        segControl.selectorTextColor = .mainBackground.withAlphaComponent(0.7)
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
    
    private let emptyRankView: UIView = {
        let view = EmptyRankView()
        view.isHidden = true
        return view
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        setRefreshControl()
    }
    
    override func setupLayout() {
        view.addSubviews(segControl, listCollectionView, cameraButton, emptyRankView)
        
        let segControlConstraints = [
            segControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            segControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
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
        
        let emptyRankViewConstraints = [
            emptyRankView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyRankView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        
        [segControlConstraints, listCollectionViewConstraints, cameraButtonConstraints, emptyRankViewConstraints]
            .forEach { constraints in
                NSLayoutConstraint.activate(constraints)
            }
    }
    
    private func setRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        refreshControl.tintColor = .black
        listCollectionView.refreshControl = refreshControl
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        title = "괴인 랭킹"
        let logoImageView = makeBarButtonItem(with: logoImageView)
        let helpButton = makeBarButtonItem(with: helpButton)
        navigationItem.leftBarButtonItem = logoImageView
        navigationItem.rightBarButtonItem = helpButton
    }
    
    private func loadData() {
        Task {
            if let result = await FirebaseManager.shared.loadMonsters(term: term, pages: pages) {
                self.monsters = result.monsters
                self.cursor = result.cursor
            }
            
            DispatchQueue.main.async {
                self.listCollectionView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private func continueData() {
        guard dataMayContinue, let cursor = cursor else { return }
        dataMayContinue = false
        
        Task {
            if let result = await FirebaseManager.shared.continueMonsters(term: term, cursor: cursor, pages: pages) {
                self.monsters += result.monsters
                self.cursor = result.cursor
            }
            
            DispatchQueue.main.async {
                self.listCollectionView.reloadData()
            }
            
            self.dataMayContinue = true
        }
    }
    
    private func moveToCamera() {
        guard UserDefaults.standard.string(forKey: "nickname") != nil else {
            setNickname()
            return
        }
        
        navigationController?.pushViewController(FaceDetectionViewController(), animated: true)
    }
    
    private func setNickname() {
        let vc = SetNicknameViewController()
        vc.modalPresentationStyle = .pageSheet
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        
        present(vc, animated: true, completion: nil)
    }
    
    private func goToGetPaperViewController() {
//        guard let nickname = nicknameField.text,
//        nicknameField.text?.count != 0 else {
//            showToast()
//            return
//        }
        
//        UserDefaults.standard.set(nickname, forKey: "nickname")
//        dismiss(animated: true, completion: nil)
    }
    
    private func getPaper(monster: Monster) {
        let alert = UIAlertController(
            title: "괴인 정보",
            message: """
괴인의 수배서를 보려면
비밀번호를 입력해야 합니다.
""",
            preferredStyle: .alert
        )
        let ok = UIAlertAction(title: "확인", style: .default) { (ok) in
            guard let password = alert.textFields?[0].text,
                  password.count != 0,
                  password == monster.password
            else {
                self.showToast(message: "비밀번호를 다시 입력해주세요")
                return
            }
            let viewController = GetPaperViewController(monster: monster)
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel) { (cancel) in }
        
        alert.addAction(cancel)
        alert.addAction(ok)
        alert.addTextField { (passwordField) in
            passwordField.keyboardType = .numberPad
            passwordField.placeholder = "비밀번호"
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func refreshTable(refresh: UIRefreshControl) {
        loadData()
    }
}

// MARK: - UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        emptyRankView.isHidden = monsters.count == 0 ? false : true
        return monsters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: RankCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)

        cell.rankLabel.text = "\(indexPath.item + 1)"
        cell.nicknameLabel.text = monsters[indexPath.item].nickname
        cell.gradeLabel.text = gradeData[monsters[indexPath.item].grade]["grade"]! as? String
        cell.moneyLabel.text = "$\(numberFormatter(number: monsters[indexPath.item].score))"
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        getPaper(monster: monsters[indexPath.item])
    }
}

extension MainViewController: MSegmentedControlDelegate {
    func segSelectedIndexChange(to index: Int) {
        term = index
        loadData()
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
