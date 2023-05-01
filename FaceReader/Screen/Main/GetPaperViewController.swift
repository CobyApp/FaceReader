//
//  GetPaperViewController.swift
//  FaceReader
//
//  Created by COBY_PRO on 2023/05/02.
//

import UIKit

import SDWebImage

final class GetPaperViewController: BaseViewController {
    private enum Size {
        static let wantedWidth: CGFloat = UIScreen.main.bounds.size.width
        static let wantedHeight: CGFloat = wantedWidth * 1.8
    }
    
    private let monster: Monster
    
    init(monster: Monster) {
        self.monster = monster
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var shareLabel: UILabel = {
        let label = UILabel()
        label.text = "공유"
        label.textColor = .mainText
        label.font = .font(.regular, ofSize: 20)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapShareLabel))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
        return label
    }()
    
    private let scrollView : UIScrollView! = UIScrollView()
    private let contentView : UIView! = UIView()
    
    private let wantedImageView = UIImageView()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .mainText.withAlphaComponent(0.5)
        button.setTitle("괴인 삭제", for: .normal)
        button.titleLabel?.font = .font(.regular, ofSize: 22)
        let action = UIAction { [weak self] _ in
            self?.deleteButtonTouched(button)
        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wantedImageView.sd_setImage(with: URL(string: monster.imageUrl))
    }
    
    override func setupLayout() {
        view.addSubviews(scrollView, deleteButton)
        scrollView.addSubviews(contentView)
        contentView.addSubviews(wantedImageView)
        
        let contentViewHeight = contentView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor)
        contentViewHeight.priority = .defaultLow
        contentViewHeight.isActive = true
        
        scrollView.showsVerticalScrollIndicator = false
        
        let scrollViewConstraints = [
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: deleteButton.topAnchor)
        ]
        
        let contentViewConstraints = [
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: Size.wantedHeight)
        ]
        
        let wantedImageViewConstraints = [
            wantedImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            wantedImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            wantedImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            wantedImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ]
        
        let deleteButtonConstraints = [
            deleteButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            deleteButton.heightAnchor.constraint(equalToConstant: 80)
        ]
        
        [
            scrollViewConstraints,
            contentViewConstraints,
            wantedImageViewConstraints,
            deleteButtonConstraints
        ].forEach { constraints in
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        let shareLabelView = makeBarButtonItem(with: shareLabel)
        navigationItem.rightBarButtonItem = shareLabelView
        title = "괴인 정보"
    }
    
    private func showToast(message: String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height - 80, width: 150, height: 35))
        toastLabel.backgroundColor = .mainText.withAlphaComponent(0.6)
        toastLabel.textColor = .mainBackground
        toastLabel.font = .font(.regular, ofSize: 20)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    @objc private func didTapShareLabel(sender: UITapGestureRecognizer) {
        let wantedImage = contentView.asImage()
        var shareObject = [UIImage]()
        
        shareObject.append(wantedImage)
        
        let activityViewController = UIActivityViewController(activityItems : shareObject, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToFacebook,
            UIActivity.ActivityType.postToTwitter,
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.copyToPasteboard,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.openInIBooks,
            UIActivity.ActivityType.markupAsPDF
        ]

        self.present(activityViewController, animated: true)
    }
    
    @IBAction
    func deleteButtonTouched(_ sender: Any) {
        let alert = UIAlertController(
            title: "괴인 삭제",
            message: """
괴인을 삭제하기 위해서
설정된 비밀번호를 입력해야 합니다.
""",
            preferredStyle: .alert
        )
        let ok = UIAlertAction(title: "확인", style: .default) { (ok) in
            guard let password = alert.textFields?[0].text,
                  password.count != 0
            else {
                self.showToast(message: "비밀번호를 다시 입력해주세요")
                return
            }
//            self.deleteMonster(password: password)
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
}
