//
//  AuthorizationViewController.swift
//  Instagram
//
//  Created by Inna Kokorina on 11.04.2022.
//

import UIKit
import Firebase
import FirebaseAuth

class AuthorizationViewController: UIViewController {
    var signup: Bool = true {
        willSet {
            if newValue {
                titleLabel.text = Constants.Auth.createUser
                infoLabel.text = Constants.Auth.infoCreate
                switchButton.setTitle(Constants.Auth.switchButtonSignIn, for: .normal)
            } else{
                titleLabel.text = Constants.Auth.signIn
                infoLabel.text = Constants.Auth.infoSignIn
                switchButton.setTitle(Constants.Auth.switchButtonCreate, for: .normal)
            }
        }
    }
    // MARK: - View
    private var backImage:UIImageView = {
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
        setConstraints()
        switchButton.addTarget(self, action: #selector(switchPressed), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(signInPressed), for: .touchUpInside)
        emailField.delegate = self
        passwordField.delegate = self
    }
}
// MARK: - setConstraints
extension AuthorizationViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            verStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            verStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 70),
            view.trailingAnchor.constraint(equalTo: verStackView.trailingAnchor, constant: 20),
            
            backImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            backImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            view.trailingAnchor.constraint(equalTo: backImage.trailingAnchor, constant: 0),
            view.bottomAnchor.constraint(equalTo: backImage.bottomAnchor, constant: 0),
            
            signInButton.heightAnchor.constraint(equalToConstant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: verStackView.leadingAnchor, constant: 0),
            titleLabel.trailingAnchor.constraint(equalTo: verStackView.trailingAnchor, constant: 0),
            infoLabel.leadingAnchor.constraint(equalTo: verStackView.leadingAnchor, constant: 0),
            infoLabel.trailingAnchor.constraint(equalTo: verStackView.trailingAnchor, constant: 0)
        ])
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
    func showAlert(){
        let alert = UIAlertController(title: "Ошибка", message: "Пожалуйста, заполните все поля", preferredStyle: .alert)
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
                Auth.auth().createUser(withEmail: email, password: password) { result, err in
                    guard err == nil
                    else {
                        print(err!)
                        return
                    }
                    let vc = MainViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                showAlert()
            }
        } else {
            if !email.isEmpty && !password.isEmpty {
                Auth.auth().signIn(withEmail:email, password: password) { (result,err) in
                    guard err == nil
                    else {
                        print(err!)
                        return
                    }
                        let vc = MainViewController()
                        self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                showAlert()
            }
        }
        
    }
    
    func setName() -> String {
        let name = Auth.auth().currentUser?.email as? String
        return name ?? "User"
    }
}

