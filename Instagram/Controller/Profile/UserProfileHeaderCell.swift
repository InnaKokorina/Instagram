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
    let personImage = BaseUserImage(cornerRadius: 100/2)
    let userLabel = UILabel()
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
    func configure(user: UserRealm ) {
        personImage.image = FirebaseManager.shared.setImage(data: user.userPhoto)
        userLabel.text = user.userName
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
    }
}
