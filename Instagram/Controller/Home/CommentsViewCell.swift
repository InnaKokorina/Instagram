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
        var authorLabel = BaseLabel(textColor: .black, textAlignment: .left)
        authorLabel.setLabelFont(with: 17)
        return authorLabel
    }()
    var commentLabel: UILabel = {
        var textLabel = BaseLabel(textColor: .black, textAlignment: .left)
        textLabel.setLabelFont(with: 15)
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
// MARK: - setViews
    func addViews() {
        contentView.addSubview(horStackView)
    }
    func configure(indexPath: Int, comment: Results<CommentsRealm>) {
        let author = "\(comment[indexPath].email): "
        let comment = comment[indexPath].body
        commentLabel.attributedText = DataManager.shared.attributedText(normStr: comment, boldStr: author)
    }
}
    // MARK: - setConstraints
extension CommentsViewCell {
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
