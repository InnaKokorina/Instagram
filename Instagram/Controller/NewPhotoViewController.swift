//
//  NewPhotoViewController.swift
//  Instagram
//
//  Created by Inna Kokorina on 23.04.2022.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class NewPhotoViewController: UIViewController {
    private var imagePicker: ImagePicker!
    private var activeTextField : UITextView? = nil
    private var auth = AuthorizationViewController()
    private var firebaseManager = FirebaseManager()
    private var ref: DatabaseReference!
    var dataModel = DataModel(photos: [Photos]())
    private let dataManager = DataManager()
      
    private var userLabel: UILabel = {
        let userLabel = UILabel()
        userLabel.font = UIFont(name: Constants.Font.font, size: 17)
        userLabel.textAlignment = .left
        return userLabel
    }()
    private var newImage: UIImageView = {
        let newImage = UIImageView()
        newImage.contentMode = .scaleAspectFit
        newImage.translatesAutoresizingMaskIntoConstraints = false
        newImage.clipsToBounds = true
        newImage.layer.cornerRadius = 15
        newImage.image = UIImage(named: "addImage")
        newImage.contentMode = .scaleAspectFill
        newImage.isUserInteractionEnabled = true
        newImage.tintColor = .gray
        return newImage
    }()
    private let photoTextField: UITextView = {
        let photoTextField = UITextView()
        photoTextField.text = Constants.ImagePicker.textPhotoPlaceholder
        photoTextField.font = UIFont(name: Constants.Font.font, size: 15)
        photoTextField.layer.shadowOpacity = 0.5
        photoTextField.layer.cornerRadius = 15
        photoTextField.isEditable = true
        photoTextField.layer.borderWidth = 1
        photoTextField.layer.borderColor = UIColor.systemGray5.cgColor
        photoTextField.textColor = .gray
        return photoTextField
    }()
    
    private lazy var verStackView = UIStackView(arrangedSubviews: [userLabel, newImage, photoTextField], axis: .vertical, spacing: 4)
    
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(verStackView)
        userLabel.text = auth.setName()
        setConstraints()
        photoTextField.delegate = self
        addNewPhoto()
        setupNavItems()
        tapImage()
        
        NotificationCenter.default.addObserver(self, selector: #selector(NewPhotoViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NewPhotoViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    // MARK: - addNewPhoto
    @objc func addNewPhoto() {
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        self.imagePicker.present(from: view)
        
    }
    
    
    // MARK: - navigationItems
    func setupNavItems() {
        let addPhoto = UIBarButtonItem(image: UIImage(systemName: "arrow.up.circle.fill"), style: .plain, target: self, action: #selector(sharePressed))
        addPhoto.tintColor = .black
        self.navigationItem.rightBarButtonItem = addPhoto
        self.navigationItem.leftBarButtonItem?.tintColor = .black
        navigationItem.title = Constants.App.title
    }
    
  // MARK: - sharePressed
    @objc func sharePressed(_ sender: Any) {

       
        
        // save image to FBStorage
        var urlString = ""
        var filePath = ""
        if let image = newImage.image {
            filePath = "\(dataManager.dateFormatter()).jpg"
            firebaseManager.create(for: image, path: filePath) { (downloadURL) in
                guard let downloadURL = downloadURL else {
                    print("Download url not found")
                    return
                }
                urlString = downloadURL
            }
        }
        // safe to FB
        dataModel.photos.append(Photos(comment: [CommentsModel](), description: photoTextField.text, id: dataModel.photos.count, image: filePath, likes: 0, link: urlString, user: userLabel.text ?? "user", liked: false))
        print("dataModel.photos.count \(dataModel.photos.count)")
        
        self.ref = Database.database().reference().child("photos/\(dataModel.photos.count - 1)")
        let post = dataModel.photos[dataModel.photos.count - 1]
    print("data model share pressed \(dataModel.photos)")
        let  dict = [
            "user": post.user,
            "description": post.description,
            "id": post.id,
            "image": post.image,
            "liked": post.liked,
            "likes": post.likes,
            "link": post.link,
            "comments": post.comment
        ] as [String : Any]
        self.ref.setValue(dict)
        
        DispatchQueue.main.async {
        let vc = MainViewController()
        self.navigationController?.pushViewController(vc, animated: true)
           
        }
    }
    
}
// MARK: - ImagePickerDelegate
extension NewPhotoViewController: ImagePickerDelegate {
    
    func didSelect(image: UIImage?) {
        self.newImage.image = image
    }
}
// MARK: - setConstraints
extension NewPhotoViewController {
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            verStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            verStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: verStackView.trailingAnchor, constant: 8),
          
            photoTextField.leadingAnchor.constraint(equalTo: verStackView.leadingAnchor, constant: 0),
            userLabel.leadingAnchor.constraint(equalTo: verStackView.leadingAnchor, constant: 0),
            
            newImage.leadingAnchor.constraint(equalTo: verStackView.leadingAnchor, constant: 0),
            newImage.trailingAnchor.constraint(equalTo: verStackView.trailingAnchor, constant: 0),
            
            userLabel.heightAnchor.constraint(equalToConstant: 70),
            newImage.heightAnchor.constraint(equalToConstant: 400),
            photoTextField.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
}
// MARK: - NewPhotoViewController
extension NewPhotoViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.activeTextField = self.photoTextField
        textView.text = ""
        photoTextField.textColor = .black
    }

    
    func textViewDidChangeSelection(_ textView: UITextView) {
        self.activeTextField = self.photoTextField
    }

    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }

    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.photoTextField.endEditing(true)
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
    }
}
