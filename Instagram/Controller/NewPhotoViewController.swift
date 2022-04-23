//
//  NewPhotoViewController.swift
//  Instagram
//
//  Created by Inna Kokorina on 23.04.2022.
//

import UIKit

class NewPhotoViewController: UIViewController {
    
    private var newImage: UIImageView = {
        let newImage = UIImageView()
        newImage.contentMode = .scaleAspectFill
        newImage.translatesAutoresizingMaskIntoConstraints = false
        newImage.clipsToBounds = true
        newImage.layer.cornerRadius = 15
        newImage.isUserInteractionEnabled = true
        newImage.image = UIImage(named: "3")
        newImage.contentMode = .scaleToFill
        return newImage
    }()
    let shareButton: UIButton = {
        let shareButton = UIButton()
        shareButton.imageView?.tintColor = .systemPink
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.contentHorizontalAlignment = .leading
        shareButton.setTitle("Опубликовать", for: .normal)
        return shareButton
    }()
    
    var imagePicker: ImagePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple
        view.addSubview(newImage)
        view.addSubview(shareButton)
        setConstraints()
        shareButton.addTarget(self, action: #selector(shareButtonPressed), for: .touchUpInside)
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    
    @objc func shareButtonPressed(_ sender: Any) {
        self.imagePicker.present(from: sender as! UIView)
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
            newImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            newImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            view.trailingAnchor.constraint(equalTo: newImage.trailingAnchor, constant: 20),
            shareButton.topAnchor.constraint(equalTo: newImage.bottomAnchor, constant: 40),
            shareButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            shareButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 40),
            newImage.heightAnchor.constraint(equalToConstant: 250)
        ])
    }
}
