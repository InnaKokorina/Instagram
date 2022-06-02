//
//  UserProfileHeaderCell.swift
//  Instagram
//
//  Created by Inna Kokorina on 23.05.2022.
//

import UIKit

class UserProfileHeaderCell: UICollectionViewCell {

    static var headerCell = "HeaderCell"
    var didSetupConstraints = false

    // MARK: - View
    let personImage: UIImageView = {
        let personImage = UIImageView()
        personImage.contentMode = .scaleAspectFill
        personImage.layer.borderWidth = 1
        personImage.layer.masksToBounds = false
        personImage.layer.borderColor = UIColor.black.cgColor
        personImage.layer.cornerRadius = 100/2
        personImage.clipsToBounds = true
        return personImage
    }()
    let userLabel: UILabel = {
        let userLabel = UILabel()
        return userLabel
    }()

    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(personImage)
        contentView.addSubview(userLabel)
        updateViewConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
// MARK: - configure
    func configure(user: Posts ) {
        personImage.image = user.image
        userLabel.text = user.user
    }
}
// MARK: - updateViewConstraints

extension UserProfileHeaderCell {
    func updateViewConstraints() {
        if !didSetupConstraints {
       
        personImage.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(30)
            make.top.equalTo(contentView).offset(30)
            make.width.height.equalTo(100)
        }
            userLabel.snp.makeConstraints { make in
                make.top.equalTo(personImage.snp.bottom).offset(10)
                make.left.equalTo(contentView).offset(30)
            }
            didSetupConstraints = true
        }
     //   super.updateViewConstraints()
    }
}
