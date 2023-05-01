//
//  BaseViewController.swift
//  FaceReader
//
//  Created by COBY_PRO on 2022/08/23.
//

import UIKit

class BaseViewController: UIViewController {
    // MARK: - property

    private lazy var backButton: UIButton = {
        let button = BackButton()
        let buttonAction = UIAction { _ in
            self.navigationController?.popViewController(animated: true)
        }
        button.addAction(buttonAction, for: .touchUpInside)
        return button
    }()

    private var activeTextField: UITextField?

    // MARK: - life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        configureUI()
        setupBackButton()
        hidekeyboardWhenTappedAround()
        setupNavigationBar()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(BaseViewController.keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(BaseViewController.keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupInteractivePopGestureRecognizer()
    }

    func setupLayout() {
        // Override Layout
    }

    func configureUI() {
        view.backgroundColor = .mainBackground
    }

    func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        let appearance = UINavigationBarAppearance()
        let font = UIFont.font(.regular, ofSize: 24)
        let largeFont = UIFont.font(.regular, ofSize: 34)

        appearance.titleTextAttributes = [.font: font]
        appearance.largeTitleTextAttributes = [.font: largeFont]
        appearance.shadowColor = .clear
        appearance.backgroundColor = .mainBackground

        navigationBar.standardAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
    }

    // MARK: - helper func

    func makeBarButtonItem<T: UIView>(with view: T) -> UIBarButtonItem {
        return UIBarButtonItem(customView: view)
    }

    func removeBarButtonItemOffset(with button: UIButton, offsetX: CGFloat = 0, offsetY: CGFloat = 0) -> UIView {
        let offsetView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        offsetView.bounds = offsetView.bounds.offsetBy(dx: offsetX, dy: offsetY)
        offsetView.addSubview(button)
        return offsetView
    }
    
    func showToast(message: String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 100, y: self.view.frame.size.height - 100, width: 200, height: 40))
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

    // MARK: - private func

    private func setupBackButton() {
        let leftOffsetBackButton = removeBarButtonItemOffset(with: backButton, offsetX: 10)
        let backButton = makeBarButtonItem(with: leftOffsetBackButton)

        navigationItem.leftBarButtonItem = backButton
    }

    func setupInteractivePopGestureRecognizer() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    // MARK: - func

    @objc
    func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }

        var shouldMoveViewUp = false

        // if active text field is not nil
        if let activeTextField = activeTextField {
            let bottomOfTextField = activeTextField.convert(activeTextField.bounds, to: view).maxY
            let topOfKeyboard = view.frame.height - keyboardSize.height

            if bottomOfTextField > topOfKeyboard {
                shouldMoveViewUp = true
            }
        }

        if shouldMoveViewUp {
            view.frame.origin.y = 0 - keyboardSize.height
        }
    }

    @objc
    func keyboardWillHide(notification _: NSNotification) {
        view.frame.origin.y = 0
    }

    @objc
    func backgroundTap(_: UITapGestureRecognizer) {
        // go through all of the textfield inside the view, and end editing thus resigning first responder
        // ie. it will trigger a keyboardWillHide notification
        view.endEditing(true)
    }
}

extension BaseViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }

    func textFieldDidEndEditing(_: UITextField) {
        activeTextField = nil
    }
}

extension BaseViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        guard let count = navigationController?.viewControllers.count else { return false }
        return count > 1
    }
}
