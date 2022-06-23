//
//  UserProfileCollectionCell.swift
//  Instagram
//
//  Created by Inna Kokorina on 23.05.2022.
//

import UIKit

class UserProfileCollectionCell: UICollectionViewCell {
    static var cellId = "CollectionViewCell"
    private let postImage: UIImageView = {
        let postImage = UIImageView()
        postImage.contentMode = .scaleAspectFill
        postImage.clipsToBounds = true
        return postImage
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(postImage)
        postImage.frame = contentView.bounds
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configure(post: PostsRealm) {
        postImage.image = UIImage(data: post.image!)
    }
}
