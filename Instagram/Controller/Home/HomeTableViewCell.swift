//
//  HomeTableViewCell.swift
//  Instagram
//
//  Created by Inna Kokorina on 20.03.2022.
//

import UIKit
import RealmSwift
import FirebaseAuth

class HomeTableViewCell: UITableViewCell {
    var likeButtomTap: (() -> Void)?
    var commentButtonPressed: (() -> Void)?
    var locationPressed:(() -> Void)?
    var authorLabelPressed:(() -> Void)?
    var  deleteItem:(() -> Void)?
    private let spinner = SpinnerViewController()
    static var identifier = "HomeTableViewCell"

    // MARK: - UIViews
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    private var authorNameLabel: UILabel = {
        let authorNameLabel = BaseLabel(textColor: .black, textAlignment: .left)
        authorNameLabel.setLabelFont(with: 17)
        return authorNameLabel
    }()
    var locationButton: UIButton = {
        let locationButton = UIButton()
        locationButton.setTitleColor(.lightGray, for: .normal)
        locationButton.setTitle("", for: .normal)
        locationButton.contentHorizontalAlignment = .left
        locationButton.titleLabel?.font = UIFont(name: Constants.Font.font, size: 14)
        return locationButton
    }()
    private var bandImage = BasePostImage()
    let likeButton: UIButton = {
        let likeButton = UIButton()
        likeButton.imageView?.tintColor = .systemPink
        likeButton.contentHorizontalAlignment = .leading
        return likeButton
    }()
    let deleteButton: UIButton = {
        let deleteButton = UIButton()
        deleteButton.contentHorizontalAlignment = .trailing
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.imageView?.tintColor = .black
        return deleteButton
    }()
    var likesCountLabel: UILabel = {
        var likesCountLabel = BaseLabel(textColor: .black, textAlignment: .left)
        likesCountLabel.setLabelFont(with: 15)
        return likesCountLabel
    }()
    private let descriptionLabel: UILabel = {
        let descriptionLabel = BaseLabel(textColor: .black, textAlignment: .left)
        descriptionLabel.setLabelFont(with: 12)
        return descriptionLabel
    }()
    var heartView: BezierHeartView = {
        var heartView = BezierHeartView()
        heartView.alpha = 0
        return heartView
    }()
    let commentsButton: UIButton = {
        let commentsButton = UIButton()
        commentsButton.setTitle(" ??????????????????????", for: .normal)
        commentsButton.titleLabel?.font = UIFont(name: Constants.Font.font, size: 14)
        commentsButton.translatesAutoresizingMaskIntoConstraints = false
        commentsButton.setTitleColor(.black, for: .normal)
        commentsButton.setImage(UIImage(systemName: "message"), for: .normal)
        return commentsButton
    }()
    private lazy var verStackView = UIStackView(arrangedSubviews: [authorNameLabel, locationButton, scrollView, horStackView, likesCountLabel, descriptionLabel, commentsButton ], axis: .vertical, spacing: 4)
    private lazy var horStackView = UIStackView(arrangedSubviews: [likeButton, deleteButton], axis: .horizontal)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addViews()
        setConstraints()
        addTargets()
        doubleTapImage()
        tapUser()
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
        horStackView.distribution = .equalSpacing
    }
    func configure (dataModel: PostsRealm) {
        verStackView.alignment = .leading
        authorNameLabel.text = dataModel.user!.userName
        descriptionLabel.text = "\(dataModel.user!.userName):  \(dataModel.descriptionImage)"
        likesCountLabel.text = DataManager.shared.likeLabelConvert(counter: dataModel.likes)
        locationButton.setTitle(dataModel.location, for: .normal)
        spinner.start(view: self.bandImage)
        setImage(image: dataModel.image)
        spinner.stop()
        selectionStyle = .none
        commentsButton.tintColor = .black
        if dataModel.user?.userId == Auth.auth().currentUser!.uid {
            deleteButton.isHidden = false
        } else {
            deleteButton.isHidden = true
        }
        if DataManager.shared.likedByUser(currentUserId: Auth.auth().currentUser!.uid, usersArray: dataModel.likedByUsers) {
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
    private func addTargets() {
        likeButton.addTarget(self, action: #selector(likePressed), for: .touchUpInside)
        commentsButton.addTarget(self, action: #selector(commentButtonpTap), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(locationTap), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTap), for: .touchUpInside)
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
    @objc func userPressed() {
        authorLabelPressed?()
    }
    @objc func deleteTap() {
       deleteItem?()
    }
    // MARK: - set image from Api or failImage
    func setImage(image: Data?) {
        if image == nil {
            bandImage.image = UIImage(systemName: "xmark.circle")
            bandImage.contentMode = .center
            bandImage.tintColor = .red
        } else {
            bandImage.image = UIImage(data: image!)
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

    func tapUser() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapUser))
        authorNameLabel.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
    }
    @objc func didTapUser(sender: UITapGestureRecognizer) {
        userPressed()
    }
}
// MARK: - constraints
extension HomeTableViewCell {
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
        horStackView.snp.makeConstraints { make in
            make.left.right.equalTo(verStackView).inset(6)
            //  make.width.equalTo(22)
        }
        likeButton.snp.makeConstraints { make in
            make.width.equalTo(22)
        }
        deleteButton.snp.makeConstraints { make in
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
