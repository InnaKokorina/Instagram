//
//  SearchViewCell.swift
//  Instagram
//
//  Created by Inna Kokorina on 08.06.2022.
//

import UIKit

class SearchViewCell: UITableViewCell {
    static var identifier = "SearchViewCell"
    var userLabel: UILabel = {
        let label = UILabel()
        label.text = "user"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    var personImage: UIImageView = {
        let personImage = UIImageView()
        personImage.contentMode = .scaleAspectFill
        personImage.image = UIImage(systemName: "person")
        personImage.layer.borderWidth = 1
        personImage.layer.masksToBounds = false
        personImage.layer.borderColor = UIColor.black.cgColor
        personImage.layer.cornerRadius = 50/2
        personImage.clipsToBounds = true
        personImage.isUserInteractionEnabled = true
        return personImage
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(personImage)
        contentView.addSubview(userLabel)
        setConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setConstraints() {
        personImage.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(10)
            make.top.bottom.equalTo(contentView).inset(10)
            make.width.height.equalTo(50)
            make.centerY.equalTo(contentView)
        }
        userLabel.snp.makeConstraints { make in
            make.left.equalTo(personImage.snp.right).offset(4)
            make.top.bottom.equalTo(contentView).offset(10)
        }
    }
}
