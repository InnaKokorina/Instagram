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
    private var networkManager = NetworkManager()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addViews()
        setConstraints()
        likeButton.addTarget(self, action: #selector(likePressed), for: .touchUpInside)
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
        authorNameLabel.font = UIFont(name: "Times New Roman", size: 17)
        authorNameLabel.textAlignment = .left
        return authorNameLabel
    }()
    private var bandImage: UIImageView = {
        let bandImage = UIImageView()
        bandImage.contentMode = .scaleToFill
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
        likesCountLabel.font = UIFont(name: "Times New Roman", size: 15)
        return likesCountLabel
    }()
    private let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont(name: "Times New Roman", size: 12)
        return descriptionLabel
    }()
    var heartView: BezierPathView = {
        var heartView = BezierPathView()
        heartView.translatesAutoresizingMaskIntoConstraints = false
        heartView.alpha = 0
        return heartView
    }()
    private lazy var verStackView = UIStackView(arrangedSubviews: [authorNameLabel, scrollView, likeButton, likesCountLabel, descriptionLabel ], axis: .vertical, spacing: 4)
    
    // MARK: - cell setup and configure
    private func addViews() {
        contentView.addSubview(verStackView)
        contentView.addSubview(scrollView)
        scrollView.addSubview(bandImage)
        bandImage.addSubview(heartView)
    }
    func configure (dataModel:[DataModel], indexPath: IndexPath) {
        verStackView.alignment = .leading
        authorNameLabel.text = dataModel[indexPath.row].author
        descriptionLabel.text = "\(dataModel[indexPath.row].author ):  \(dataModel[indexPath.row].description)"
        likesCountLabel.text = dataManager.likeLabelConvert(counter: dataModel[indexPath.row].likesCount)
        likeButton.setImage(UIImage(systemName: dataModel[indexPath.row].isLiked ? "heart.fill" : "heart"), for: .normal)
        downloadImage(from: URL(string: dataModel[indexPath.row].photoImageUrl)!)
        selectionStyle = .none
    }
    
    func downloadImage(from url: URL) {
        networkManager.getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.bandImage.image =  UIImage(data: data)
            }
        }
    }
    
    // MARK: - likeButtonPressed
    @objc  func likePressed() {
        likeButtomTap?()
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

extension MainTableViewCell: NetworkManagerImageDelegate {
    func didUpdateBandImage(data: Data) {
        DispatchQueue.main.async() { [weak self] in
            self?.bandImage.image =  UIImage(data: data)
        }
    }
}
