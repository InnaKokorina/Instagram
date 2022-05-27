//
//  CommentsViewCell.swift
//  Instagram
//
//  Created by Inna Kokorina on 06.04.2022.
//

import UIKit
import RealmSwift

class CommentsViewCell: UITableViewCell {
    var authorLabel: UILabel = {
        var authorLabel = UILabel()
        authorLabel.font = UIFont(name: Constants.Font.font, size: 17)
        authorLabel.numberOfLines = 0
        return authorLabel
    }()
    var commentLabel: UILabel = {
        var textLabel = UILabel()
        textLabel.font = UIFont(name: Constants.Font.font, size: 15)
        textLabel.numberOfLines = 0
        return textLabel
    }()
    private lazy var horStackView = UIStackView(arrangedSubviews: [commentLabel], axis: .horizontal, spacing: 4)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addViews()
        updateViewConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addViews() {
        contentView.addSubview(horStackView)
    }

    func configure(indexPath: Int, comment: Results<CommentsModel>) {
        let author = "\(comment[indexPath].email): "
        let comment = comment[indexPath].body
        commentLabel.attributedText = attributedText(normStr: comment, boldStr: author)
    }
    // MARK: - setConstraints
    func updateViewConstraints() {
            horStackView.snp.makeConstraints { make in
                make.left.right.equalTo(contentView).inset(8)
                make.top.equalTo(contentView)
                make.bottom.equalTo(contentView).inset(10)
            }
            commentLabel.snp.makeConstraints { make in
                make.left.right.equalTo(horStackView).inset(6)
            }
        }
    }
// MARK: - attributedText
extension CommentsViewCell {
    func attributedText(normStr: String, boldStr: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: normStr)
        let attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)]
        let boldString = NSMutableAttributedString(string: boldStr, attributes: attrs)
        boldString.append(attributedString)
        return boldString
    }
}
