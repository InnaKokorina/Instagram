//
//  UserProfileNoPostsCell.swift
//  Instagram
//
//  Created by Inna Kokorina on 02.06.2022.
//

import UIKit

class UserProfileNoPostsCell: UICollectionViewCell {
    private let noPostsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "Публикаций пока нет..."
        label.textColor = .lightGray
        label.textAlignment = .center
        return label
    }()

    static var cellId = "userProfileNoPostsCellId"

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(noPostsLabel)
        noPostsLabel.frame = contentView.bounds
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
