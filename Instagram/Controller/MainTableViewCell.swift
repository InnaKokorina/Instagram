//
//  MainTableViewCell.swift
//  Instagram
//
//  Created by Inna Kokorina on 20.03.2022.
//

import UIKit


class MainTableViewCell: UITableViewCell {
    var likeButtomTap: (() -> Void)?
    var shareButtonTap: (() -> Void)?
    
    static var identifier = "MainTableViewCell"
    
    
    private var dataManager = DataManager()
    
    var counter = 0
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        setConstraints()
        likeButton.addTarget(self, action: #selector(likePressed), for: .touchUpInside)
     //   shareButton.addTarget(self, action: #selector(sharePressed), for: .touchUpInside)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    private var authorNameLabel: UILabel = {
        let authorNameLabel = UILabel()
        authorNameLabel.font = UIFont(name: "Rockwell", size: 17)
        authorNameLabel.textAlignment = .left
        return authorNameLabel
    }()
    private var bandImage: UIImageView = {
        let bandImage = UIImageView()
        bandImage.contentMode = .scaleToFill
        bandImage.translatesAutoresizingMaskIntoConstraints = false
        return bandImage
    }()
    
    private let likeButton: UIButton = {
        let likeButton = UIButton()
        likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        likeButton.imageView?.tintColor = .systemPink
        return likeButton
    }()
    
    private let shareButton: UIButton = {
        let shareButton = UIButton()
        shareButton.setImage(UIImage(systemName: "paperplane"), for: .normal)
        shareButton.imageView?.tintColor = .black
        return shareButton
    }()
    var likesCountLabel: UILabel = {
        var likesCountLabel = UILabel()
        likesCountLabel.font = UIFont(name: "Rockwell", size: 15)
        return likesCountLabel
    }()
    
    private  lazy var horStackView = UIStackView(arrangedSubviews: [likeButton, shareButton], axis: .horizontal, spacing: 20)
    
    private let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont(name: "Verdana", size: 12)
        return descriptionLabel
    }()
    
    let heartImage: UIImageView = {
        let heartImage = UIImageView()
        heartImage.image = UIImage(systemName: "heart.fill")
        heartImage.translatesAutoresizingMaskIntoConstraints = false
        heartImage.tintColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        heartImage.alpha = 0
        return heartImage
    }()
    
    
    
    private lazy var verStackView = UIStackView(arrangedSubviews: [authorNameLabel, bandImage, horStackView, likesCountLabel, descriptionLabel ], axis: .vertical, spacing: 4)
    
    
    // MARK: - cell setup and configure
    
    private func setup() {
        contentView.addSubview(horStackView)
        contentView.addSubview(verStackView)
        contentView.addSubview(heartImage)
    }
    
    func configure (with image : UIImage, dataModel:[DataModel], indexPath: IndexPath) {
        authorNameLabel.text = dataModel[indexPath.row].author
        descriptionLabel.text = dataModel[indexPath.row].author + dataModel[indexPath.row].description
        likesCountLabel.text = dataManager.likeLabelConvert(counter: dataModel[indexPath.row].likesCount)
        horStackView.distribution = .fillProportionally
        bandImage.image = image
        selectionStyle = .none
    }
    // MARK: - likeButtonPressed
    @objc  func likePressed() {
        likeButtomTap?()
        
    }
    // MARK: - shareButtonPressed
//    @objc  func  sharePressed () {
//        shareButtonTap?()
//
//
//  }
    // MARK: - constraints
    
    private func setConstraints() {
        
        NSLayoutConstraint.activate([
            verStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            verStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            contentView.trailingAnchor.constraint(equalTo: verStackView.trailingAnchor, constant: 0),
            contentView.bottomAnchor.constraint(equalTo: verStackView.bottomAnchor, constant: 10),
            bandImage.leadingAnchor.constraint(equalTo: verStackView.leadingAnchor, constant: 0),
            descriptionLabel.leadingAnchor.constraint(equalTo: verStackView.leadingAnchor, constant: 6),
            authorNameLabel.leadingAnchor.constraint(equalTo: verStackView.leadingAnchor, constant: 6),
            likesCountLabel.leadingAnchor.constraint(equalTo: verStackView.leadingAnchor, constant: 6)
            
        ])
        
        
        NSLayoutConstraint.activate([
            bandImage.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        NSLayoutConstraint.activate([
            heartImage.leadingAnchor.constraint(equalTo: bandImage.leadingAnchor, constant: 40),
            heartImage.topAnchor.constraint(equalTo: bandImage.topAnchor, constant: 70),
            bandImage.trailingAnchor.constraint(equalTo: heartImage.trailingAnchor, constant: 40),
            bandImage.bottomAnchor.constraint(equalTo: heartImage.bottomAnchor, constant: 70),
            
        ])
        
    }
}




