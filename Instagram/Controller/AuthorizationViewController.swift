//
//  AuthorizationViewController.swift
//  Instagram
//
//  Created by Inna Kokorina on 11.04.2022.
//

import UIKit
import Firebase
import FirebaseAuth
import SnapKit

class AuthorizationViewController: UIViewController {
    var didSetupConstraints = false
    var signup: Bool = true {
        willSet {
            if newValue {
                titleLabel.text = Constants.Auth.createUser
                infoLabel.text = Constants.Auth.infoCreate
                switchButton.setTitle(Constants.Auth.switchButtonSignIn, for: .normal)
            } else {
                titleLabel.text = Constants.Auth.signIn
                infoLabel.text = Constants.Auth.infoSignIn
                switchButton.setTitle(Constants.Auth.switchButtonCreate, for: .normal)
            }
        }
    }
    // MARK: - View
    private var backImage: UIImageView = {
        let backImage = UIImageView()
        backImage.image = UIImage(named: Constants.Auth.backImageName)
        backImage.contentMode = .scaleAspectFill
        backImage.alpha = 0.3
        backImage.translatesAutoresizingMaskIntoConstraints = false
        return backImage
    }()
    private var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont(name: Constants.Font.font, size: 30)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.text = Constants.Auth.createUser
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    private var infoLabel: UILabel = {
        let infoLabel = UILabel()
        infoLabel.font = UIFont(name: Constants.Font.font, size: 14)
        infoLabel.textAlignment = .center
        infoLabel.text = Constants.Auth.infoCreate
        infoLabel.numberOfLines = 0
        infoLabel.textColor = .white
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        return infoLabel
    }()
    private var emailField: UITextField = {
        let emailField = UITextField()
        emailField.font = UIFont(name: Constants.Font.font, size: 17)
        emailField.textAlignment = .left
        emailField.placeholder = Constants.Auth.placeholderEmail
        emailField.borderStyle = .roundedRect
        emailField.textContentType = .emailAddress
        emailField.translatesAutoresizingMaskIntoConstraints = false
        emailField.keyboardType = .emailAddress
        emailField.autocorrectionType = .yes
        return emailField
    }()

    private var passwordField: UITextField = {
        let passwordField = UITextField()
        passwordField.font = UIFont(name: Constants.Font.font, size: 17)
        passwordField.textAlignment = .left
        passwordField.placeholder = Constants.Auth.placeholderPassword
        passwordField.borderStyle = .roundedRect
        passwordField.textContentType = .password
        passwordField.isSecureTextEntry = true
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        return passwordField
    }()
    private var switchButton: UIButton = {
        let switchButton = UIButton()
        switchButton.backgroundColor = .gray
        switchButton.setTitle(Constants.Auth.switchButtonSignIn, for: .normal)
        switchButton.setTitleColor(.black, for: .normal)
        if #available(iOS 15.0, *) {
            switchButton.configuration?.cornerStyle = .dynamic
            switchButton.layer.cornerRadius = 5
        }
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        return switchButton
    }()
    private var signInButton: UIButton = {
        let signInButton = UIButton()
        signInButton.backgroundColor = .white
        signInButton.setTitle("Go!", for: .normal)
        signInButton.setTitleColor(.black, for: .normal)
        if #available(iOS 15.0, *) {
            signInButton.configuration?.cornerStyle = .dynamic
            signInButton.layer.cornerRadius = 5
        }
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        return signInButton
    }()
    private lazy var verStackView = UIStackView(arrangedSubviews: [titleLabel, infoLabel, emailField, passwordField, signInButton, switchButton], axis: .vertical, spacing: 20)
    // MARK: - lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(backImage)
        verStackView.contentMode = .center
        verStackView.distribution = .fillProportionally
        view.addSubview(verStackView)
        view.setNeedsUpdateConstraints()
        switchButton.addTarget(self, action: #selector(switchPressed), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(signInPressed), for: .touchUpInside)
        emailField.delegate = self
        passwordField.delegate = self
    }
}
// MARK: - setConstraints
extension AuthorizationViewController {
    override func updateViewConstraints() {
        if !didSetupConstraints {
            verStackView.snp.makeConstraints { make in
                make.top.equalTo(view).inset(70)
                make.leading.equalTo(view).inset(20)
                make.trailing.equalTo(view).inset(20)
            }
            backImage.snp.makeConstraints { make in
                make.edges.equalTo(view).inset(UIEdgeInsets.zero)
            }
            titleLabel.snp.makeConstraints { make in
                make.leading.equalTo(verStackView)
                make.trailing.equalTo(verStackView)
            }
            infoLabel.snp.makeConstraints { make in
                make.leading.equalTo(verStackView)
                make.trailing.equalTo(verStackView)
            }
            signInButton.snp.makeConstraints { make in
                make.height.equalTo(40)
            }
            didSetupConstraints = true
        }
        super.updateViewConstraints()
    }
}

// MARK: - UITextFieldDelegate
extension AuthorizationViewController: UITextFieldDelegate {

    @objc func switchPressed() {
        self.signup.toggle()
        emailField.endEditing(true)
        passwordField.text = ""
        emailField.text = ""
    }
    func showAlert(choice: Int) {
        var message = ""
        switch choice {
        case 1 : message = "Пожалуйста, заполните все поля"
        case 2 : message = "Email адрес или пароль введены некорректно, либо учетная запись с таким email уже существует"
        case 3 : message = "Такой учетной записи не существует. Проверьте email адрес или пароль"
        default: message = "ошибка"
        }
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    @objc func signInPressed() {
        checkAuth()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        checkAuth()
        return true
    }

    func checkAuth() {
        let email = emailField.text!
        let password = passwordField.text!
        if signup {
            if !email.isEmpty && !password.isEmpty {
                Auth.auth().createUser(withEmail: email, password: password) { _, err in
                    guard err == nil
                    else {
                        self.showAlert(choice: 2)
                        return
                    }
                    let viewController = MainViewController()
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            } else {
                showAlert(choice: 1)
            }
        } else {
            if !email.isEmpty && !password.isEmpty {
                Auth.auth().signIn(withEmail: email, password: password) { (_, err) in
                    guard err == nil
                    else {
                        self.showAlert(choice: 3)
                        return
                    }
                        let viewController = MainViewController()
                        self.navigationController?.pushViewController(viewController, animated: true)
                }
            } else {
                showAlert(choice: 1)
            }
        }

    }

    func setName() -> String {
        let name = Auth.auth().currentUser?.email as? String
        return name ?? "User"
    }
}
