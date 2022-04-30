//
//  MainTableViewCell.swift
//  Instagram
//
//  Created by Inna Kokorina on 20.03.2022.
//

import UIKit
import RealmSwift

class MainTableViewCell: UITableViewCell {
    var likeButtomTap: (() -> Void)?
    var commentButtonPressed: (() -> Void)?
    static var identifier = "MainTableViewCell"
    private var dataManager = DataManager()
    let spinner = SpinnerViewController()
    private let firebaseManager = FirebaseManager()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addViews()
        setConstraints()
        likeButton.addTarget(self, action: #selector(likePressed), for: .touchUpInside)
        commentsButton.addTarget(self, action: #selector(commentButtonpTap), for: .touchUpInside)
        doubleTapImage()
        scrollViewSet()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViews
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    private var authorNameLabel: UILabel = {
        let authorNameLabel = UILabel()
        authorNameLabel.font = UIFont(name: Constants.Font.font, size: 17)
        authorNameLabel.textAlignment = .left
        return authorNameLabel
    }()
    private var bandImage: UIImageView = {
        let bandImage = UIImageView()
        bandImage.contentMode = .scaleAspectFill
        bandImage.translatesAutoresizingMaskIntoConstraints = false
        bandImage.clipsToBounds = true
        bandImage.layer.cornerRadius = 15
        bandImage.isUserInteractionEnabled = true
        return bandImage
    }()
    let likeButton: UIButton = {
        let likeButton = UIButton()
        likeButton.imageView?.tintColor = .systemPink
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.contentHorizontalAlignment = .leading
        return likeButton
    }()
    var likesCountLabel: UILabel = {
        var likesCountLabel = UILabel()
        likesCountLabel.font = UIFont(name: Constants.Font.font, size: 15)
        return likesCountLabel
    }()
    private let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont(name: Constants.Font.font, size: 12)
        return descriptionLabel
    }()
    var heartView: BezierHeartView = {
        var heartView = BezierHeartView()
        heartView.translatesAutoresizingMaskIntoConstraints = false
        heartView.alpha = 0
        return heartView
    }()
    let commentsButton: UIButton = {
        let commentsButton = UIButton()
        commentsButton.setTitle(" Комментарии", for: .normal)
        commentsButton.titleLabel?.font = UIFont(name: Constants.Font.font, size: 14)
        commentsButton.translatesAutoresizingMaskIntoConstraints = false
        commentsButton.setTitleColor(.black, for: .normal)
        commentsButton.setImage(UIImage(systemName: "message"), for: .normal)
        return commentsButton
    }()
    private lazy var verStackView = UIStackView(arrangedSubviews: [authorNameLabel, scrollView, likeButton, likesCountLabel, descriptionLabel, commentsButton ], axis: .vertical, spacing: 4)
    
    // MARK: - cell setup and configure
    private func addViews() {
        contentView.addSubview(verStackView)
        contentView.addSubview(scrollView)
        scrollView.addSubview(bandImage)
        bandImage.addSubview(heartView)
    }
    func configure (dataModel: Results<Photos>, indexPath: IndexPath) {
        verStackView.alignment = .leading
        authorNameLabel.text = dataModel[indexPath.row].user
        descriptionLabel.text = "\(dataModel[indexPath.row].user ):  \(dataModel[indexPath.row].descriptionImage)"
        likesCountLabel.text = dataManager.likeLabelConvert(counter: dataModel[indexPath.row].likes)
        likeButton.setImage(UIImage(systemName: dataModel[indexPath.row].liked ? "heart.fill" : "heart"), for: .normal)
        self.spinner.start(view: self.bandImage)
        //firebaseManager.getImage(picName: dataModel[indexPath.row].imageName) { pic in
      //  self.setImage(image: Data(referencing: dataModel[indexPath.row].image!))
            self.spinner.stop()
      //  }
        selectionStyle = .none
        commentsButton.tintColor = .black
    }
    
    // prepare for reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        self.bandImage.image = nil
        
    }
    // MARK: - buttons pressed
    @objc  func likePressed() {
        likeButtomTap?()
    }
    @objc  func  commentButtonpTap (_ sender: UIButton) {
        commentButtonPressed?()
    }
    
    // MARK: - set image from Api or failImage
    func setImage(image: Data) {
        // if image == UIImage(systemName: "xmark.circle") {
             bandImage.contentMode = .center
             bandImage.tintColor = .red
             self.bandImage.image = UIImage(data: image)
 //        } else {
 //            self.bandImage.image = image
 //        }
     }
    // MARK: - constraints
    private func setConstraints() {
        NSLayoutConstraint.activate([
            verStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            verStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            contentView.trailingAnchor.constraint(equalTo: verStackView.trailingAnchor, constant: 8),
            contentView.bottomAnchor.constraint(equalTo: verStackView.bottomAnchor, constant: 10),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: verStackView.leadingAnchor, constant: 6),
            authorNameLabel.leadingAnchor.constraint(equalTo: verStackView.leadingAnchor, constant: 6),
            likesCountLabel.leadingAnchor.constraint(equalTo: verStackView.leadingAnchor, constant: 6),
            likeButton.leadingAnchor.constraint(equalTo: verStackView.leadingAnchor, constant: 6),
            likeButton.widthAnchor.constraint(equalToConstant: 22),
            
            scrollView.topAnchor.constraint(equalTo: authorNameLabel.bottomAnchor, constant: 4),
            scrollView.leadingAnchor.constraint(equalTo: verStackView.leadingAnchor, constant: 0),
            scrollView.trailingAnchor.constraint(equalTo: verStackView.trailingAnchor, constant: 0),
            likeButton.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 4),
        ])
        
        NSLayoutConstraint.activate([
            bandImage.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0),
            bandImage.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0),
            scrollView.trailingAnchor.constraint(equalTo: bandImage.trailingAnchor, constant: 0),
            scrollView.bottomAnchor.constraint(equalTo: bandImage.bottomAnchor, constant: 0),
        ])
        
        NSLayoutConstraint.activate([
            scrollView.heightAnchor.constraint(equalToConstant: 400),
            bandImage.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            bandImage.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        NSLayoutConstraint.activate([
            heartView.leadingAnchor.constraint(equalTo: bandImage.leadingAnchor, constant: 40),
            heartView.topAnchor.constraint(equalTo: bandImage.topAnchor, constant: 100),
            bandImage.trailingAnchor.constraint(equalTo: heartView.trailingAnchor, constant: 40),
            bandImage.bottomAnchor.constraint(equalTo: heartView.bottomAnchor, constant: 100)
        ])
    }
}

// MARK: - viewForZooming
extension MainTableViewCell: UIScrollViewDelegate {
    func scrollViewSet() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        scrollView.bouncesZoom = false
        bandImage.isUserInteractionEnabled = true
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return bandImage
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollView.zoomScale = 1.0
    }
}
// MARK: - doubleTapImage
extension MainTableViewCell {
    func doubleTapImage() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapImage))
        tapGesture.numberOfTapsRequired = 2
        bandImage.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
    }
    @objc func didDoubleTapImage(sender: UITapGestureRecognizer)
    {
        likePressed()
    }
    
}
