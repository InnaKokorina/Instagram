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
import RealmSwift
import YPImagePicker

class AuthorizationViewController: UIViewController {
    private var didSetupConstraints = false
    private let imagePicker = YPImagePickerView()
    private var selectedItems = [YPMediaItem]()
    private let realm = try! Realm()
    private let spinner = SpinnerViewController()
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
        let titleLabel = BaseLabel(textColor: .white, textAlignment: .center, text: Constants.Auth.createUser)
        titleLabel.setLabelFont(with: 30)
        return titleLabel
    }()
    private var infoLabel: UILabel = {
        let infoLabel = BaseLabel(textColor: .white, textAlignment: .center, text: Constants.Auth.infoCreate)
        infoLabel.setLabelFont(with: 14)
        return infoLabel
    }()
    private var photoView: UIView = {
        let photoView = UIView()
        return photoView
    }()
    let personImage = BaseUserImage(cornerRadius: 100/2)

    private var switchButton: UIButton = {
        let switchButton = BaseButton(backgroundColor: .gray)
        switchButton.setTitle(Constants.Auth.switchButtonCreate, for: .normal)
        switchButton.setTitleColor(.black, for: .normal)
        return switchButton
    }()
    private var signInButton: UIButton = {
        let signInButton = BaseButton(backgroundColor: .white)
        signInButton.setTitle(Constants.Auth.buttonTitle, for: .normal)
        signInButton.setTitleColor(.black, for: .normal)
        return signInButton
    }()
    private let spinnerImage: UIImageView = {
        let spinnerImage = UIImageView()
        spinnerImage.contentMode = .center
        spinnerImage.translatesAutoresizingMaskIntoConstraints = false
        return spinnerImage
    }()
    private lazy var nameField = BaseTextField(placeholder: Constants.Auth.placeholderName, textContentType: .name, keyboardType: .default)
    private lazy var emailField = BaseTextField(placeholder: Constants.Auth.placeholderEmail, textContentType: .emailAddress, keyboardType: .emailAddress)
    private lazy var passwordField = BaseTextField(placeholder: Constants.Auth.placeholderPassword, textContentType: .password, keyboardType: .default)
    private lazy var verStackView = UIStackView(arrangedSubviews: [titleLabel, infoLabel, photoView, nameField, emailField, passwordField, signInButton, switchButton], axis: .vertical, spacing: 10)

    // MARK: - lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setViews()
        emailField.delegate = self
        passwordField.delegate = self
        signIn = true
        tapImage()
    }
    func setViews() {
        view.addSubview(backImage)
        view.addSubview(verStackView)
        verStackView.contentMode = .center
        verStackView.distribution = .fillProportionally
        passwordField.isSecureTextEntry = true
        photoView.addSubview(personImage)
        signInButton.addSubview(spinnerImage)
        view.setNeedsUpdateConstraints()
        switchButton.addTarget(self, action: #selector(switchPressed), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(signInPressed), for: .touchUpInside)
    }
}
// MARK: - UITextFieldDelegate
extension AuthorizationViewController: UITextFieldDelegate {
    @objc func switchPressed() {
        self.signIn.toggle()
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
    // MARK: - checkAuth
    func checkAuth() {
        signInButton.setTitle("", for: .normal)
        let email = emailField.text!
        let password = passwordField.text!
        let name = nameField.text!
        if signIn == false {
            if !email.isEmpty && !password.isEmpty && !name.isEmpty {
                spinner.start(view: spinnerImage)
                Auth.auth().createUser(withEmail: email, password: password ) { result, err in
                    guard err == nil
                    else {
                        self.showAlert(message: ErrorReason.incorrectData.description)
                        return
                    }
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
                                        let user = UserRealm(userId: result.user.uid, userName: name, userEmail: email)
                                        FirebaseManager.shared.getImage(picName: "\(email).jpg") { data in
                                            user.userPhoto = data
                                            do {
                                                try self.realm.write {
                                                    self.realm.add(user)
                                                    self.spinner.stop()
                                                    self.navigationController?.dismiss(animated: true)
                                                }
                                            } catch {
                                                print("Error saving Data context \(error)")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                showAlert(message: ErrorReason.emptyFields.description)
            }
        } else {
            if !email.isEmpty && !password.isEmpty {
                spinner.start(view: spinnerImage)
                Auth.auth().signIn(withEmail: email, password: password) { _, err in
                    guard err == nil
                    else {
                        self.showAlert(message: ErrorReason.noAccount.description)
                        return
                    }
                    self.spinner.stop()
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
// MARK: - YPImagePickerDelegate
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
            spinnerImage.snp.makeConstraints { make in
                make.center.equalTo(signInButton)
            }
            didSetupConstraints = true
        }
        super.updateViewConstraints()
    }
}
// MARK: - ErrorReason
enum ErrorReason {
    case emptyFields
    case incorrectData
    case noAccount

    var description: String {
        switch self {
        case .emptyFields: return Constants.Auth.errorEmptyFields
        case .incorrectData: return Constants.Auth.errorIncorrectData
        case .noAccount: return Constants.Auth.errorNoAccount
        }
    }
}
