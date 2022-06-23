//
//  ChatViewCell.swift
//  Instagram
//
//  Created by Inna Kokorina on 09.06.2022.
//

import UIKit

class ChatViewCell: UITableViewCell {
    static var identifier = "ChatViewCell"
    var userLabel: UILabel = {
        let label = BaseLabel(textColor: .black, textAlignment: .left, text: "User")
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userLabel)
        userLabel.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(10)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
