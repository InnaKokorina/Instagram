//
//  AuthorizationViewController.swift
//  Instagram
//
//  Created by Inna Kokorina on 11.04.2022.
//

import UIKit
import FirebaseAuth

class AuthorizationViewController: UIViewController {
    var signup:Bool = true {
        willSet {
            if newValue {
                titleLabel.text = "Создайте аккаунт"
                infoLabel.text = "Заполните данные в полях ниже, чтобы создать учетную запись"
                signInButton.setTitle("Есть аккаунт? Войти", for: .normal)
                
            } else{
                titleLabel.text = "Войдите в аккаунт"
                infoLabel.text = "Войдите в систему, чтобы продолжить работу в приложении"
                signInButton.setTitle("Создать аккаунт", for: .normal)
            }
        }
    }
    private var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont(name: "Times New Roman", size: 30)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.text = "Создайте аккаунт"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    private var infoLabel: UILabel = {
        let infoLabel = UILabel()
        infoLabel.font = UIFont(name: "Times New Roman", size: 14)
        infoLabel.textAlignment = .center
        infoLabel.text = "Заполните данные в полях ниже, чтобы создать учетную запись"
        infoLabel.numberOfLines = 0
        infoLabel.textColor = .white
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        return infoLabel
    }()
    private var emailField: UITextField = {
        let emailField = UITextField()
        emailField.font = UIFont(name: "Times New Roman", size: 17)
        emailField.textAlignment = .left
        emailField.placeholder = "Введите email"
        emailField.borderStyle = .roundedRect
        emailField.textContentType = .emailAddress
        emailField.translatesAutoresizingMaskIntoConstraints = false
        return emailField
    }()
    
    private var passwordField: UITextField = {
        let passwordField = UITextField()
        passwordField.font = UIFont(name: "Times New Roman", size: 17)
        passwordField.textAlignment = .left
        passwordField.placeholder = "Введите пароль"
        passwordField.borderStyle = .roundedRect
        passwordField.textContentType = .password
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        return passwordField
    }()
    
    private var signInButton: UIButton = {
        let signInButton = UIButton()
        signInButton.backgroundColor = .white
        signInButton.setTitle("Есть аккаунт? Войти", for: .normal)
        signInButton.setTitleColor(.black, for: .normal)
        if #available(iOS 15.0, *) {
            signInButton.configuration?.cornerStyle = .dynamic
            signInButton.layer.cornerRadius = 5 //signInButton.frame.height/3
        }
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        return signInButton
    }()
    private lazy var verStackView = UIStackView(arrangedSubviews: [titleLabel, infoLabel, emailField, passwordField,signInButton], axis: .vertical, spacing: 20)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verStackView.contentMode = .center
        verStackView.distribution = .fillProportionally
        view.addSubview(verStackView)
        setConstraints()
        signInButton.addTarget(self, action: #selector(signInPressed), for: .touchUpInside)
        emailField.delegate = self
        passwordField.delegate = self
    }
}
extension AuthorizationViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            verStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            verStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 70),
            view.trailingAnchor.constraint(equalTo: verStackView.trailingAnchor, constant: 20),
            
            
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
    func showAlert(){
        let alert = UIAlertController(title: "Ошибка", message: "Пожалуйста, заполните все поля", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    @objc func signInPressed() {
        passwordField.endEditing(true)
        emailField.endEditing(true)
        passwordField.text = ""
        emailField.text = ""
        self.signup.toggle()
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let email = emailField.text!
        let password = passwordField.text!
        
        if (signup){
            if(!email.isEmpty && !password.isEmpty) {
                
                Auth.auth().createUser(withEmail: email, password: password) {  result, err in
                    if err == nil {
                        if let result = result {
                            print(result.user.uid)
                            let vc = MainViewController()
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            }else{
                showAlert()
            }
        } else {
            if (!email.isEmpty && !password.isEmpty){
                Auth.auth().signIn(withEmail:email, password: password) { (result,err) in
                    if err == nil {
                        let vc = MainViewController()
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            } else{
                showAlert()
            }
        }
        return true
    }
}
