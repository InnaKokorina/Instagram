//
//  CommentsViewCell.swift
//  Instagram
//
//  Created by Inna Kokorina on 06.04.2022.
//

import UIKit

class CommentsViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addViews()
        setConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var authorLabel: UILabel = {
        var authorLabel = UILabel()
        authorLabel.font = UIFont(name: "Times New Roman", size: 15)
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        return authorLabel
    }()
    
    var commentLabel: UILabel = {
        var textLabel = UILabel()
        textLabel.font = UIFont(name: "Times New Roman", size: 15)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
    }()
    
    private lazy var horStackView = UIStackView(arrangedSubviews: [authorLabel, commentLabel], axis: .horizontal, spacing: 4)
    func addViews() {
        contentView.addSubview(horStackView)

    }
    
    
    func configure() {
        authorLabel.text = " Auhtor :"
        commentLabel.text = " some comment"
        
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            horStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            horStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            contentView.trailingAnchor.constraint(equalTo: horStackView.trailingAnchor, constant: 8),
            contentView.bottomAnchor.constraint(equalTo: horStackView.bottomAnchor, constant: 10),
            
            authorLabel.leadingAnchor.constraint(equalTo: horStackView.leadingAnchor, constant: 6),
            commentLabel.trailingAnchor.constraint(equalTo: authorLabel.leadingAnchor, constant: -6)
        ])
}
}
