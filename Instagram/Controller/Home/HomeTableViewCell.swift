//
//  HomeTableViewCell.swift
//  Instagram
//
//  Created by Inna Kokorina on 20.03.2022.
//

import UIKit
import RealmSwift

class HomeTableViewCell: UITableViewCell {
    var likeButtomTap: (() -> Void)?
    var commentButtonPressed: (() -> Void)?
    var locationPressed:(() -> Void)?
    private let spinner = SpinnerViewController()
    private var dataManager = DataManager()
    private let firebaseManager = FirebaseManager()
    static var identifier = "HomeTableViewCell"

    // MARK: - UIViews
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    private var authorNameLabel: UILabel = {
        let authorNameLabel = UILabel()
        authorNameLabel.font = UIFont(name: Constants.Font.font, size: 17)
        authorNameLabel.textAlignment = .left
        return authorNameLabel
    }()
    private var locationButton: UIButton = {
        let locationButton = UIButton()
        locationButton.setTitleColor(.lightGray, for: .normal)
        locationButton.setTitle("Location", for: .normal)
        locationButton.contentHorizontalAlignment = .left
        locationButton.titleLabel?.font = UIFont(name: Constants.Font.font, size: 14)
        return locationButton
    }()
    private var bandImage: UIImageView = {
        let bandImage = UIImageView()
        bandImage.contentMode = .scaleAspectFill
        bandImage.clipsToBounds = true
        bandImage.layer.cornerRadius = 15
        bandImage.isUserInteractionEnabled = true
        return bandImage
    }()
    let likeButton: UIButton = {
        let likeButton = UIButton()
        likeButton.imageView?.tintColor = .systemPink
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
    private lazy var verStackView = UIStackView(arrangedSubviews: [authorNameLabel, locationButton, scrollView, likeButton, likesCountLabel, descriptionLabel, commentsButton ], axis: .vertical, spacing: 4)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addViews()
        setConstraints()
        likeButton.addTarget(self, action: #selector(likePressed), for: .touchUpInside)
        commentsButton.addTarget(self, action: #selector(commentButtonpTap), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(locationTap), for: .touchUpInside)
        doubleTapImage()
        scrollViewSet()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - cell setup and configure
    private func addViews() {
        contentView.addSubview(verStackView)
        scrollView.addSubview(bandImage)
        bandImage.addSubview(heartView)
    }
    func configure (dataModel: [Posts], indexPath: IndexPath) {
        verStackView.alignment = .leading
        authorNameLabel.text = dataModel[indexPath.row].user.userName
        descriptionLabel.text = "\(dataModel[indexPath.row].user.userName):  \(dataModel[indexPath.row].descriptionImage)"
        likesCountLabel.text = dataManager.likeLabelConvert(counter: dataModel[indexPath.row].likes)
        likeButton.setImage(UIImage(systemName: dataModel[indexPath.row].liked ? "heart.fill" : "heart"), for: .normal)
        locationButton.setTitle(dataModel[indexPath.row].location, for: .normal)
        spinner.start(view: self.bandImage)
        setImage(image: dataModel[indexPath.row].image)
        spinner.stop()
        selectionStyle = .none
        commentsButton.tintColor = .black
    }

    // prepare for reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        bandImage.image = nil

    }
    // MARK: - buttons pressed
    @objc  func likePressed() {
        likeButtomTap?()
    }
    @objc  func  commentButtonpTap(_ sender: UIButton) {
        commentButtonPressed?()
    }
    @objc func locationTap(_ sender: UIButton) {
       locationPressed?()
    }

    // MARK: - set image from Api or failImage
    func setImage(image: UIImage?) {
        if image == nil {
            bandImage.image = UIImage(systemName: "xmark.circle")
             bandImage.contentMode = .center
             bandImage.tintColor = .red
       } else {
           bandImage.image = image
      }
     }
    // MARK: - constraints
    private func setConstraints() {
        verStackView.snp.makeConstraints { make in
            make.left.right.equalTo(contentView).inset(8)
            make.top.equalTo(contentView)
            make.bottom.equalTo(contentView).offset(-8)
        }
        authorNameLabel.snp.makeConstraints { make in
            make.left.right.equalTo(verStackView).inset(6)
        }
        locationButton.snp.makeConstraints { make in
            make.left.right.equalTo(verStackView).inset(6)
            make.height.equalTo(20)
        }
        scrollView.snp.makeConstraints { make in
            make.left.right.equalTo(verStackView)
            make.height.equalTo(400)
        }
        bandImage.snp.makeConstraints { make in
            make.edges.equalTo(scrollView).inset(UIEdgeInsets.zero)
            make.center.equalTo(scrollView)
        }
        heartView.snp.makeConstraints { make in
            make.left.right.equalTo(bandImage).inset(40)
            make.top.bottom.equalTo(bandImage).inset(100)
        }
        likeButton.snp.makeConstraints { make in
            make.left.equalTo(verStackView).inset(6)
            make.width.equalTo(22)
        }
        likesCountLabel.snp.makeConstraints { make in
            make.left.equalTo(6)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.left.right.equalTo(verStackView).inset(6)
        }
    }
}

// MARK: - viewForZooming
extension HomeTableViewCell: UIScrollViewDelegate {
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
extension HomeTableViewCell {
    func doubleTapImage() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapImage))
        tapGesture.numberOfTapsRequired = 2
        bandImage.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
    }
    @objc func didDoubleTapImage(sender: UITapGestureRecognizer) {
        likePressed()
    }

}
