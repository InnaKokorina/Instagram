//
//  NewPhotoViewController.swift
//  Instagram
//
//  Created by Inna Kokorina on 23.04.2022.
//

import UIKit

class NewPhotoViewController: UIViewController {
   private var imagePicker: ImagePicker!
   private var activeTextField : UITextField? = nil
    private var auth = AuthorizationViewController()
    
    private var userLabel: UILabel = {
        let userLabel = UILabel()
        userLabel.font = UIFont(name: Constants.Font.font, size: 17)
        userLabel.textAlignment = .left
        return userLabel
    }()
    private var newImage: UIImageView = {
        let newImage = UIImageView()
        newImage.contentMode = .scaleAspectFill
        newImage.translatesAutoresizingMaskIntoConstraints = false
        newImage.clipsToBounds = true
        newImage.layer.cornerRadius = 15
        newImage.image = UIImage(systemName: "photo.on.rectangle")
        newImage.contentMode = .scaleAspectFit
        newImage.isUserInteractionEnabled = true
        newImage.backgroundColor = .white
        newImage.tintColor = .gray
        return newImage
    }()
    private let photoTextField: UITextField = {
        let photoTextField = UITextField()
        photoTextField.placeholder = Constants.ImagePicker.textPhotoPlaceholder
        photoTextField.font = UIFont(name: Constants.Font.font, size: 15)
        photoTextField.borderStyle = .roundedRect
        return photoTextField
    }()
    
    private lazy var verStackView = UIStackView(arrangedSubviews: [userLabel, newImage, photoTextField], axis: .vertical, spacing: 4)
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray5
        view.addSubview(verStackView)
        userLabel.text = auth.setName()
        setConstraints()
        photoTextField.delegate = self
        addNewPhoto()
//        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
//        self.imagePicker.present(from: view)
//
        setupNavItems()
        tapImage()
        
        NotificationCenter.default.addObserver(self, selector: #selector(NewPhotoViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NewPhotoViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func addNewPhoto() {
       // var imagePicker: ImagePicker!
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        self.imagePicker.present(from: view)
    }


// MARK: - navigationItems
func setupNavItems() {
    let addPhoto = UIBarButtonItem(image: UIImage(systemName: "arrow.up.circle.fill"), style: .plain, target: self, action: #selector(sharePressed))
    addPhoto.tintColor = .black
    self.navigationItem.rightBarButtonItem = addPhoto
    self.navigationItem.rightBarButtonItem?.tintColor = .black
    navigationItem.title = Constants.App.title
}


@objc func sharePressed(_ sender: Any) {
    let vc = MainViewController()
    self.navigationController?.pushViewController(vc, animated: true)
}

}
extension NewPhotoViewController: ImagePickerDelegate {
    
    func didSelect(image: UIImage?) {
        self.newImage.image = image
    }
}

extension NewPhotoViewController {
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            verStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            verStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: verStackView.trailingAnchor, constant: 8),
            //view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: verStackView.bottomAnchor, constant: 8),
            
            photoTextField.leadingAnchor.constraint(equalTo: verStackView.leadingAnchor, constant: 0),
            userLabel.leadingAnchor.constraint(equalTo: verStackView.leadingAnchor, constant: 0),
            
         //   newImage.topAnchor.constraint(equalTo: userLabel.bottomAnchor, constant: 0),
            newImage.leadingAnchor.constraint(equalTo: verStackView.leadingAnchor, constant: 0),
            newImage.trailingAnchor.constraint(equalTo: verStackView.trailingAnchor, constant: 0),
            //photoTextField.topAnchor.constraint(equalTo: newImage.bottomAnchor, constant: 0),

            userLabel.heightAnchor.constraint(equalToConstant: 70),
            newImage.heightAnchor.constraint(equalToConstant: 400),
            photoTextField.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
}

extension NewPhotoViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = self.photoTextField
        print(activeTextField?.text ?? "nil")
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.activeTextField = self.photoTextField
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
                self.photoTextField.endEditing(true)
        }
}



 //MARK: - keyboardWillShow
extension NewPhotoViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        var shouldMoveViewUp = false
        if let activeTextField = activeTextField {
            let bottomOfTextField = activeTextField.convert(activeTextField.bounds, to: self.view).maxY;
            let topOfKeyboard = self.view.frame.height - keyboardSize.height
            if bottomOfTextField > topOfKeyboard {
                shouldMoveViewUp = true
            }
            if shouldMoveViewUp {
                self.view.frame.origin.y = 0 - keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
}

// MARK: - TapImage
extension NewPhotoViewController: UIGestureRecognizerDelegate  {
    func tapImage() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        newImage.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
    }
    @objc func didTapImage(sender: UITapGestureRecognizer) {
        addNewPhoto()
        print("add")
    }
    
}
