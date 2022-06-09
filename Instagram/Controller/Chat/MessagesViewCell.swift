//
//  MessagesViewCell.swift
//  Instagram
//
//  Created by Inna Kokorina on 09.06.2022.
//

import UIKit

class MessagesViewCell: UITableViewCell {

    var leftUserLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    var rightUserLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    var messageView: UIView = {
        let messageView = UIView()
        messageView.backgroundColor = UIColor(red: 0.90, green: 0.81, blue: 1, alpha: 1)
        messageView.layer.cornerRadius = 8
        return messageView
    }()
    var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Книга преобразила мир. В ней память человеческого рода, она рупор человеческой мысли. Мир без книги – мир дикарей. Книги суть зерцало: хотя и не говорят, всякому вину и порок объявляют. Екатерина Великая."
        label.font = UIFont(name: Constants.Font.font, size: 15)
        return label
    }()
    private lazy var horStackView = UIStackView(arrangedSubviews: [leftUserLabel, messageView, rightUserLabel], axis: .horizontal, spacing: 20)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addViews()
        updateViewConstraints()
        messageLabel.numberOfLines = 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func addViews() {
        contentView.addSubview(horStackView)
        messageView.addSubview(messageLabel)
        horStackView.distribution = .fill
    }
    func updateViewConstraints() {
            horStackView.snp.makeConstraints { make in
                make.left.right.equalTo(contentView).inset(10)
                make.right.equalTo(contentView)
                make.top.equalTo(contentView).offset(10)
                make.bottom.equalTo(contentView).offset(-10)
            }
        leftUserLabel.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.left.equalTo(horStackView)
        }
        rightUserLabel.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.right.equalTo(horStackView)
        }
        messageLabel.snp.makeConstraints { make in
            make.left.right.equalTo(messageView).inset(10)
            make.right.equalTo(messageView)
            make.top.equalTo(messageView).offset(10)
            make.bottom.equalTo(messageView).offset(-10)
            }
        }
    }
