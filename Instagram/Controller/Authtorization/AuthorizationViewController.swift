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
import YPImagePicker

class AuthorizationViewController: UIViewController {
    var didSetupConstraints = false
    let imagePicker = YPImagePickerView()
    var selectedItems = [YPMediaItem]()
    var signIn: Bool = true {
        willSet {
            if newValue {
                titleLabel.text = Constants.Auth.signIn
                infoLabel.text = Constants.Auth.infoSignIn
                personImage.isHidden = true
                nameField.isHidden = true
                photoView.isHidden = true
                switchButton.setTitle(Constants.Auth.switchButtonCreate, for: .normal)
            } else {
                titleLabel.text = Constants.Auth.createUser
                infoLabel.text = Constants.Auth.infoCreate
                nameField.isHidden = false
                personImage.isHidden = false
                photoView.isHidden = false
                switchButton.setTitle(Constants.Auth.switchButtonSignIn, for: .normal)
            }
        }
    }
    // MARK: - View
    private var backImage: UIImageView = {
        let backImage = UIImageView()
        backImage.image = UIImage(named: Constants.Auth.backImageName)
        backImage.contentMode = .scaleAspectFill
        backImage.alpha = 0.3
        return backImage
    }()
    private var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont(name: Constants.Font.font, size: 30)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.text = Constants.Auth.createUser
        return titleLabel
    }()
    private var infoLabel: UILabel = {
        let infoLabel = UILabel()
        infoLabel.font = UIFont(name: Constants.Font.font, size: 14)
        infoLabel.textAlignment = .center
        infoLabel.text = Constants.Auth.infoCreate
        infoLabel.numberOfLines = 0
        infoLabel.textColor = .white
        return infoLabel
    }()
    private var photoView: UIView = {
        let photoView = UIView()
        return photoView
    }()
    let personImage: UIImageView = {
        let personImage = UIImageView()
        personImage.contentMode = .scaleAspectFill
        personImage.image = UIImage(named: "add")
        personImage.layer.borderWidth = 1
        personImage.layer.masksToBounds = false
        personImage.layer.borderColor = UIColor.black.cgColor
        personImage.layer.cornerRadius = 100/2
        personImage.clipsToBounds = true
        personImage.isUserInteractionEnabled = true
        return personImage
    }()
    private var nameField: UITextField = {
        let nameField = UITextField()
        nameField.font = UIFont(name: Constants.Font.font, size: 17)
        nameField.textAlignment = .left
        nameField.placeholder = Constants.Auth.placeholderName
        nameField.borderStyle = .roundedRect
        nameField.textContentType = .name
        nameField.autocorrectionType = .yes
        return nameField
    }()
    private var emailField: UITextField = {
        let emailField = UITextField()
        emailField.font = UIFont(name: Constants.Font.font, size: 17)
        emailField.textAlignment = .left
        emailField.placeholder = Constants.Auth.placeholderEmail
        emailField.borderStyle = .roundedRect
        emailField.textContentType = .emailAddress
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
        return passwordField
    }()
    private var switchButton: UIButton = {
        let switchButton = UIButton()
        switchButton.backgroundColor = .gray
        switchButton.setTitle(Constants.Auth.switchButtonCreate, for: .normal)
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
        signInButton.setTitle(Constants.Auth.buttonTitle, for: .normal)
        signInButton.setTitleColor(.black, for: .normal)
        signInButton.layer.borderWidth = 1.5
        signInButton.layer.borderColor = UIColor.black.cgColor
        if #available(iOS 15.0, *) {
            signInButton.configuration?.cornerStyle = .dynamic
            signInButton.layer.cornerRadius = 5
        }
        return signInButton
    }()

    private lazy var verStackView = UIStackView(arrangedSubviews: [titleLabel, infoLabel, photoView, nameField, emailField, passwordField, signInButton, switchButton], axis: .vertical, spacing: 10)

    // MARK: - lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(backImage)
        verStackView.contentMode = .center
        verStackView.distribution = .fillProportionally
        view.addSubview(verStackView)
        photoView.addSubview(personImage)
        view.setNeedsUpdateConstraints()
        switchButton.addTarget(self, action: #selector(switchPressed), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(signInPressed), for: .touchUpInside)
        emailField.delegate = self
        passwordField.delegate = self
        signIn = true
        tapImage()
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
            photoView.snp.makeConstraints { make in
                make.height.equalTo(100)
            }

            personImage.snp.makeConstraints { make in
                make.centerX.equalTo(photoView)
                make.width.height.equalTo(100)
            }
            nameField.snp.makeConstraints { make in
                make.height.equalTo(40)
            }
            emailField.snp.makeConstraints { make in
                make.height.equalTo(40)
            }
            passwordField.snp.makeConstraints { make in
                make.height.equalTo(40)
            }
            signInButton.snp.makeConstraints { make in
                make.height.equalTo(40)
            }
            switchButton.snp.makeConstraints { make in
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
        self.signIn.toggle()
       // emailField.endEditing(true)
        passwordField.text = ""
        emailField.text = ""
    }
    func showAlert(message: String) {
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
        let name = nameField.text!
        if signIn == false {
            if !email.isEmpty && !password.isEmpty && !name.isEmpty {
                Auth.auth().createUser(withEmail: email, password: password ) { result, err in
                    guard err == nil
                    else {
                        self.showAlert(message: ErrorReason.incorrectData.description)
                        return
                    }
                   // var urlString = ""
                    var filePath = ""
                    if let image = self.personImage.image {
                        filePath = "\(email).jpg"
                        DispatchQueue.global().async {
                            FirebaseManager.shared.uploadImage(for: image, path: filePath) { [self] (downloadURL) in
                                if  downloadURL == nil {
                                    print("Download url not found")
                                    return
                                } else {
                                   // urlString = downloadURL!
                                    if let result = result {
                                    let ref = Database.database().reference().child("users")
                                    ref.child(result.user.uid).updateChildValues(["name": name, "email": email])
                                    }
                                }
                            }
                        }
                    }
                    self.navigationController?.dismiss(animated: true)
                }
            } else {
                showAlert(message: ErrorReason.emptyFields.description)
            }
        } else {
            if !email.isEmpty && !password.isEmpty {
                Auth.auth().signIn(withEmail: email, password: password) { (_, err) in
                    guard err == nil
                    else {
                        self.showAlert(message: ErrorReason.noAccount.description)
                        return
                    }
                    self.navigationController?.dismiss(animated: true)
                }
            } else {
                showAlert(message: ErrorReason.emptyFields.description)
            }
        }

    }

    func setName() -> String {
        let name = Auth.auth().currentUser?.email as? String
        return name ?? "User"
    }
}
// MARK: - tapGesture
extension AuthorizationViewController: UIGestureRecognizerDelegate {
    func tapImage() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
                personImage.addGestureRecognizer(tapGesture)
                tapGesture.delegate = self
    }
    @objc func didTapImage(sender: UITapGestureRecognizer) {
        addNewPhoto()
    }
}
extension AuthorizationViewController: YPImagePickerDelegate {
    @objc func showResults() {
           if !selectedItems.isEmpty {
               let gallery = YPSelectionsGalleryVC(items: selectedItems) { gallery, _ in
                   gallery.dismiss(animated: true, completion: nil)
               }
               let navVC = UINavigationController(rootViewController: gallery)
               self.present(navVC, animated: true, completion: nil)
           } else {
               self.navigationController?.popViewController(animated: false)
               print("No items selected yet.")
           }
       }
       @objc func addNewPhoto() {
           var config = imagePicker.setConfig()
           config.library.preselectedItems = selectedItems
           let picker = YPImagePicker(configuration: config)
           picker.imagePickerDelegate = self
           picker.didFinishPicking { [weak picker] items, cancelled in
               if cancelled {
               picker?.dismiss(animated: true, completion: nil)
               self.navigationController?.popViewController(animated: false)
               } else {
               self.selectedItems = items
               self.personImage.image = items.singlePhoto?.image
               picker?.dismiss(animated: true, completion: nil)
               }
           }
           present(picker, animated: true, completion: nil)
       }
   func imagePickerHasNoItemsInLibrary(_ picker: YPImagePicker) {
   }

   func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
       return true
   }
}

// MARK: - ErrorReason
enum ErrorReason {
    case emptyFields
    case incorrectData
    case noAccount

    var description: String {
        switch self {
        case .emptyFields: return "Пожалуйста, заполните все поля"
        case .incorrectData: return "Email адрес или пароль введены некорректно, либо учетная запись с таким email уже существует"
        case .noAccount: return "Такой учетной записи не существует. Проверьте email адрес или пароль"
        }
    }
}
