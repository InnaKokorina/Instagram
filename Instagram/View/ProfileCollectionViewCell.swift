//
//  ProfileCollectionViewCell.swift
//  Instagram
//
//  Created by Inna Kokorina on 23.05.2022.
//

import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {
    static var cellId = "CollectionViewCell"

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(postImage)
        postImage.frame = contentView.bounds
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let postImage: UIImageView = {
        let postImage = UIImageView()
        postImage.contentMode = .scaleAspectFill
        postImage.clipsToBounds = true
        return postImage
    }()

    func configure() {
        postImage.image = UIImage(named: "1")
    }
}
