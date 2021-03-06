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
import SnapKit

class NewPhotoViewController: UIViewController {
    private var activeTextField: UITextView?
    private let realm = try! Realm()
    private let spinner = SpinnerViewController()
    var didSetupConstraints = false
    var dataModel: Results<PostsRealm>?
    let imagePicker = YPImagePickerView()
    var selectedItems = [YPMediaItem]()
    // MARK: - View
    private var userLabel: UILabel = {
        let userLabel = BaseLabel(textColor: .black, textAlignment: .left)
        userLabel.setLabelFont(with: 17)
        return userLabel
    }()
    private var locationButton: UIButton = {
        let locationButton = UIButton()
        locationButton.setTitleColor(.gray, for: .normal)
        locationButton.setTitle("Location", for: .normal)
        locationButton.contentHorizontalAlignment = .left
        locationButton.titleLabel?.font = UIFont(name: Constants.Font.font, size: 14)
        return locationButton
    }()
    var newImage: UIImageView = {
        let newImage = BaseUserImage(cornerRadius: 15)
        newImage.image = UIImage(named: "add")
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
        let addButton = BaseButton(backgroundColor: .black)
        addButton.tintColor = .white
        addButton.setTitle("????????????????????", for: .normal)
        return addButton
    }()
    private let spinnerImage: UIImageView = {
        let spinnerImage = UIImageView()
        spinnerImage.contentMode = .center
        spinnerImage.translatesAutoresizingMaskIntoConstraints = false
        return spinnerImage
    }()
    private lazy var verStackView = UIStackView(arrangedSubviews: [userLabel, locationButton, newImage, photoTextField, addButton], axis: .vertical, spacing: 4)

    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setViews()
        setUser()
        addNewPhoto()
        setupNavItems()
        view.setNeedsUpdateConstraints()
        photoTextField.delegate = self
    }
    func setViews() {
        view.addSubview(verStackView)
        addButton.addSubview(spinnerImage)
        spinnerImage.frame = addButton.frame
        addButton.addTarget(self, action: #selector(sharePressed), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(locationTap), for: .touchUpInside)
    }
    func setUser() {
       let users = realm.objects(UserRealm.self)
        for eachUser in users where eachUser.userId == Auth.auth().currentUser!.uid {
            userLabel.text = eachUser.userName
        }
    }
    // MARK: - sharePressed
    @objc func sharePressed(_ sender: Any) {
        spinner.start(view: spinnerImage)
        addButton.setTitle("", for: .normal)
        // save image to FBStorage
        if let image = self.newImage.image {
            let filePath = DataManager.shared.dateFormatter()
           let filePathStr = "\(filePath).jpg"
            DispatchQueue.global().async {
                FirebaseManager.shared.uploadImage(for: image, path: filePathStr) { [self] (downloadURL) in
                    if  downloadURL == nil {
                        self.addButton.imageView?.isHidden = true
                        self.spinner.stop()
                        self.addButton.setTitle("??????????????????", for: .normal)
                        print("Download url not found")
                        return
                    } else {
                       let urlString = downloadURL!
                        FirebaseManager.shared.saveNewPhotoToRealmAndFB(dataModel: dataModel, filePathStr: filePathStr, urlString: urlString, location: locationButton.currentTitle!, descriptionTextField: self.photoTextField.text)
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: false)
                            self.spinner.stop()
                        }
                    }
                }
            }
        }
    }

    // MARK: - YPImagePicker
 @objc func showResults() {
        if !selectedItems.isEmpty {
            let gallery = YPSelectionsGalleryVC(items: selectedItems) { gallery, _ in
                gallery.dismiss(animated: true, completion: nil)
            }
            let navC = UINavigationController(rootViewController: gallery)
            self.present(navC, animated: true, completion: nil)
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
            self.newImage.image = items.singlePhoto?.image
            picker?.dismiss(animated: true, completion: nil)
            }
        }
        present(picker, animated: true, completion: nil)
    }
}

// YPImagePickerDelegate
extension NewPhotoViewController: YPImagePickerDelegate {
    func imagePickerHasNoItemsInLibrary(_ picker: YPImagePicker) {
    }

    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return true
    }
}

// MARK: - setConstraints
extension NewPhotoViewController {
    override func updateViewConstraints() {
        if !didSetupConstraints {
        verStackView.snp.makeConstraints { make in
            make.left.right.equalTo(view).inset(8)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
        }
        userLabel.snp.makeConstraints { make in
            make.left.right.equalTo(verStackView)
            make.height.equalTo(24)
        }
            locationButton.snp.makeConstraints { make in
                make.left.right.equalTo(verStackView)
                make.height.equalTo(20)
            }
        newImage.snp.makeConstraints { make in
            make.left.right.equalTo(verStackView)
            make.height.equalTo(400)
        }
        photoTextField.snp.makeConstraints { make in
            make.left.right.equalTo(verStackView)
        }
        addButton.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(verStackView)
            make.height.equalTo(70)
        }
        spinnerImage.snp.makeConstraints { make in
            make.center.equalTo(addButton)
        }
            didSetupConstraints = true
        }
        super.updateViewConstraints()
    }
}
// MARK: - navigationItems
extension NewPhotoViewController {
    func setupNavItems() {
        let addPhoto = UIBarButtonItem(image: UIImage(systemName: "arrow.up.circle.fill"), style: .plain, target: self, action: #selector(sharePressed))
        addPhoto.tintColor = .black
        navigationItem.rightBarButtonItem = addPhoto
        let back = UIBarButtonItem(image: UIImage(systemName: "chevron.compact.left"), style: .plain, target: self, action: #selector(backPressed))
        back.tintColor = .black
        navigationItem.leftBarButtonItem = back
        navigationItem.title = Constants.App.titleNewPhoto
    }
    @objc func backPressed() {
        navigationController?.popViewController(animated: true)
    }
    @objc func locationTap() {
        let mapVC = MapViewController()
        mapVC.searchPoint = locationButton.currentTitle!
        self.navigationController?.pushViewController(mapVC, animated: true)
        mapVC.delegate = self
    }
}
// MARK: - NewPhotoViewController
extension NewPhotoViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        photoTextField.textColor = .black
    }
}
extension NewPhotoViewController: MapViewControllerDelegate {
    func saveLocation(with location: String) {
        locationButton.setTitle(location, for: .normal)
    }
}
