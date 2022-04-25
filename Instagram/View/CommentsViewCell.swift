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
        authorLabel.font = UIFont(name: Constants.Font.font, size: 17)
        authorLabel.numberOfLines = 0
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        return authorLabel
    }()
    
    var commentLabel: UILabel = {
        var textLabel = UILabel()
        textLabel.font = UIFont(name: Constants.Font.font, size: 15)
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
    }()
    
    private lazy var horStackView = UIStackView(arrangedSubviews: [commentLabel], axis: .horizontal, spacing: 4)
    func addViews() {
        contentView.addSubview(horStackView)
}
    
    func configure(indexPath: Int, comment: [CommentsModel]) {
        let author = "\(comment[indexPath].email): "
        let comment = comment[indexPath].body
        commentLabel.attributedText = attributedText(normStr: comment, boldStr: author)
    }
    // MARK: - setConstraints
    private func setConstraints() {
        NSLayoutConstraint.activate([
            horStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            horStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            contentView.trailingAnchor.constraint(equalTo: horStackView.trailingAnchor, constant: 8),
            contentView.bottomAnchor.constraint(equalTo: horStackView.bottomAnchor, constant: 10),
            
            commentLabel.leadingAnchor.constraint(equalTo: horStackView.leadingAnchor, constant: 6),
            commentLabel.trailingAnchor.constraint(equalTo: commentLabel.leadingAnchor, constant: -6)
        ])
    }
}
// MARK: - attributedText
extension CommentsViewCell {
    func attributedText(normStr: String, boldStr: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: normStr)
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)]
        let boldString = NSMutableAttributedString(string: boldStr, attributes:attrs)
        boldString.append(attributedString)
        return boldString
    }
}
