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
import RealmSwift
import YPImagePicker
import UIKit

class NewPhotoViewController: UIViewController {
    
    private var activeTextField : UITextView? = nil
    private var auth = AuthorizationViewController()
    private var firebaseManager = FirebaseManager()
    private var ref: DatabaseReference!
    private let dataManager = DataManager()
    private let realm = try! Realm()
    private let spinner = SpinnerViewController()
    var dataModel: Results<Photos>?
    var selectedItems = [YPMediaItem]()
    // MARK: - View
    private var userLabel: UILabel = {
        let userLabel = UILabel()
        userLabel.font = UIFont(name: Constants.Font.font, size: 17)
        userLabel.textAlignment = .left
        return userLabel
    }()
    var newImage: UIImageView = {
        let newImage = UIImageView()
        newImage.contentMode = .scaleAspectFit
        newImage.translatesAutoresizingMaskIntoConstraints = false
        newImage.clipsToBounds = true
        newImage.layer.cornerRadius = 15
        newImage.image = UIImage(named: "add")
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
        photoTextField.layer.borderColor = UIColor.systemGray4.cgColor
        photoTextField.textColor = .gray
        return photoTextField
    }()
    private let addButton: UIButton = {
        let addButton = UIButton()
        addButton.backgroundColor = .black
        addButton.tintColor = .white
        addButton.setTitle("Поделиться", for: .normal)
        addButton.layer.cornerRadius = 15
        addButton.translatesAutoresizingMaskIntoConstraints = false
        return addButton
    }()
    private let spinnerImage: UIImageView = {
        let spinnerImage = UIImageView()
        spinnerImage.contentMode = .center
        spinnerImage.translatesAutoresizingMaskIntoConstraints = false
        return spinnerImage
    }()
    private lazy var verStackView = UIStackView(arrangedSubviews: [userLabel, newImage, photoTextField, addButton], axis: .vertical, spacing: 8)
    
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        view.addSubview(verStackView)
        addButton.addSubview(spinnerImage)
        spinnerImage.frame = addButton.frame
        userLabel.text = auth.setName()
        setConstraints()
        photoTextField.delegate = self
        addNewPhoto()
        setupNavItems()
        tapImage()
        addButton.addTarget(self, action: #selector(sharePressed), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(NewPhotoViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NewPhotoViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
 
    // MARK: - navigationItems
    func setupNavItems() {
        let addPhoto = UIBarButtonItem(image: UIImage(systemName: "arrow.up.circle.fill"), style: .plain, target: self, action: #selector(sharePressed))
        addPhoto.tintColor = .black
        navigationItem.rightBarButtonItem = addPhoto
        let back = UIBarButtonItem(image: UIImage(systemName: "chevron.compact.left"), style: .plain, target: self, action: #selector(backPressed))
        back.tintColor = .black
        navigationItem.leftBarButtonItem = back
        navigationItem.title = Constants.App.title
    }
    
    @objc func backPressed() {
        navigationController?.popViewController(animated: true)
    }
    // MARK: - sharePressed
    @objc func sharePressed(_ sender: Any) {
        spinner.start(view: spinnerImage)
        addButton.setTitle("", for: .normal)
        // save image to FBStorage
        var urlString = ""
        var filePath = ""
        if let image = self.newImage.image {
            filePath = "\(self.dataManager.dateFormatter()).jpg"
            DispatchQueue.global().async {
                self.firebaseManager.uploadImage(for: image, path: filePath) { [self] (downloadURL) in
                    if  downloadURL == nil {
                        self.addButton.imageView?.isHidden = true
                        self.spinner.stop()
                        self.addButton.setTitle("Повторить", for: .normal)
                        print("Download url not found")
                        return
                    } else {
                        urlString = downloadURL!
                        
                        // save to Realm
                        let post = Photos(comment: List<CommentsModel>(), id: self.dataModel?.count ?? 0, imageName: filePath, likes: 0, link: urlString, user: userLabel.text ?? "user", liked: false, descriptionImage: self.photoTextField.text)
                        self.firebaseManager.getImage(picName: filePath) { data in
                            post.image = data
                            do {
                                try self.realm.write {
                                    self.realm.add(post)
                                    let index:Int = (self.dataModel?.count ?? 1) - 1
                                    self.ref = Database.database().reference().child("photos/\(index)")
                                    // save to FB
                                    let  dict = [
                                        "user": post.user,
                                        "description": post.descriptionImage,
                                        "id": post.id,
                                        "image": post.imageName,
                                        "liked": post.liked,
                                        "likes": post.likes,
                                        "link": post.link,
                                        "comments": Array(post.comment)
                                    ] as [String : Any]
                                    self.ref.setValue(dict)
                                    // Navigation
                                    
                                    DispatchQueue.main.async {
                                        self.navigationController?.popViewController(animated: false)
                                        self.spinner.stop()
                                        
                                    }
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
    
    // MARK: - YPImagePicker
    
 @objc func showResults() {
        if !selectedItems.isEmpty {
            let gallery = YPSelectionsGalleryVC(items: selectedItems) { g, _ in
                g.dismiss(animated: true, completion: nil)
            }
            let navC = UINavigationController(rootViewController: gallery)
            self.present(navC, animated: true, completion: nil)
        } else {
            print("No items selected yet.")
        }
    }
  @objc func addNewPhoto() {
        var config = YPImagePickerConfiguration()
        config.library.onlySquare = true
        config.onlySquareImagesFromCamera = true
        config.library.mediaType = .photo
        config.library.itemOverlayType = .grid
        config.shouldSaveNewPicturesToAlbum = false
        config.startOnScreen = .library
        config.screens = [.library, .photo]
        config.library.minWidthForItem = UIScreen.main.bounds.width * 0.8
        config.showsCrop = .rectangle(ratio: 1)
        config.wordings.libraryTitle = "Альбом"
        config.hidesStatusBar = false
        config.hidesBottomBar = false
        config.maxCameraZoomFactor = 2.0
        config.library.maxNumberOfItems = 5
        config.gallery.hidesRemoveButton = false
        config.library.preselectedItems = selectedItems
        let picker = YPImagePicker(configuration: config)
        picker.imagePickerDelegate = self
        picker.didFinishPicking { [weak picker] items, _ in
            self.selectedItems = items
            self.newImage.image = items.singlePhoto?.image
            picker?.dismiss(animated: true, completion: nil)
        }
        
        present(picker, animated: true, completion: nil)
    }
}

// YPImagePickerDelegate
extension NewPhotoViewController: YPImagePickerDelegate {
    func imagePickerHasNoItemsInLibrary(_ picker: YPImagePicker) {
    }

    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return true // indexPath.row != 2
    }
}

// MARK: - setConstraints
extension NewPhotoViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            verStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            verStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: verStackView.trailingAnchor, constant: 8),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: verStackView.bottomAnchor, constant: 16),
            
            photoTextField.leadingAnchor.constraint(equalTo: verStackView.leadingAnchor, constant: 0),
            userLabel.leadingAnchor.constraint(equalTo: verStackView.leadingAnchor, constant: 0),
            addButton.leadingAnchor.constraint(equalTo: verStackView.leadingAnchor, constant: 0),
            addButton.trailingAnchor.constraint(equalTo: verStackView.trailingAnchor, constant: 0),
            newImage.leadingAnchor.constraint(equalTo: verStackView.leadingAnchor, constant: 0),
            newImage.trailingAnchor.constraint(equalTo: verStackView.trailingAnchor, constant: 0),
            addButton.bottomAnchor.constraint(equalTo: verStackView.bottomAnchor, constant: 0),
            spinnerImage.centerXAnchor.constraint(equalTo: addButton.centerXAnchor),
            spinnerImage.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
            userLabel.heightAnchor.constraint(equalToConstant: 70),
            newImage.heightAnchor.constraint(equalToConstant: 400),
            addButton.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
}
// MARK: - NewPhotoViewController
extension NewPhotoViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextField = photoTextField
        textView.text = ""
        photoTextField.textColor = .black
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        activeTextField = photoTextField
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        photoTextField.endEditing(true)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        photoTextField.endEditing(true)
    }
}

//MARK: - keyboardWillShow
extension NewPhotoViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        var shouldMoveViewUp = false
        if let activeTextField = activeTextField {
            let bottomOfTextField = activeTextField.convert(activeTextField.bounds, to: view).maxY;
            let topOfKeyboard = view.frame.height - keyboardSize.height
            if bottomOfTextField > topOfKeyboard {
                shouldMoveViewUp = true
            }
            if shouldMoveViewUp {
                view.frame.origin.y = 0 - keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
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
