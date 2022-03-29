//
//  MainTableViewCell.swift
//  Instagram
//
//  Created by Inna Kokorina on 20.03.2022.
//

import UIKit


class MainTableViewCell: UITableViewCell, UIScrollViewDelegate {
    var likeButtomTap: (() -> Void)?
    var shareButtonTap: (() -> Void)?
    static var identifier = "MainTableViewCell"
    private var dataManager = DataManager()
    private var networkManager = NetworkManager()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        setConstraints()
        likeButton.addTarget(self, action: #selector(likePressed), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapImage))
        tapGesture.numberOfTapsRequired = 2
        bandImage.isUserInteractionEnabled = true
        bandImage.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
        //shareButton.addTarget(self, action: #selector(sharePressed), for: .touchUpInside)
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor(red: 90, green: 90, blue: 90, alpha: 0.90)
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.flashScrollIndicators()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        scrollView.zoomScale = 1.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    private var scrollView = UIScrollView()
    
    
    private var authorNameLabel: UILabel = {
        let authorNameLabel = UILabel()
        authorNameLabel.font = UIFont(name: "Times New Roman", size: 17)
        authorNameLabel.textAlignment = .left
        return authorNameLabel
    }()
    private var bandImage: UIImageView = {
        let bandImage = UIImageView()
        bandImage.contentMode = .scaleAspectFill
        bandImage.translatesAutoresizingMaskIntoConstraints = false
        return bandImage
    }()
    let likeButton: UIButton = {
        let likeButton = UIButton()
        
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
        likesCountLabel.font = UIFont(name: "Times New Roman", size: 15)
        return likesCountLabel
    }()
    private  lazy var horStackView = UIStackView(arrangedSubviews: [likeButton,shareButton], axis: .horizontal, spacing: 20)
    private let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont(name: "Times New Roman", size: 12)
        return descriptionLabel
    }()
    let heartImage: UIImageView = {
        let heartImage = UIImageView()
        heartImage.image = UIImage(systemName: "heart.fill")
        heartImage.translatesAutoresizingMaskIntoConstraints = false
        heartImage.tintColor = .systemPink
        heartImage.alpha = 0
        return heartImage
    }()
    private lazy var verStackView = UIStackView(arrangedSubviews: [authorNameLabel, scrollView, horStackView, likesCountLabel, descriptionLabel ], axis: .vertical, spacing: 4)
    
    // MARK: - cell setup and configure
    private func setup() {
        contentView.addSubview(horStackView)
        contentView.addSubview(verStackView)
        contentView.addSubview(heartImage)
        contentView.addSubview(scrollView)
        scrollView.addSubview(bandImage)
    }
    func configure (dataModel:[DataModel], indexPath: IndexPath) {
        authorNameLabel.text = dataModel[indexPath.row].author
        descriptionLabel.text = "\(dataModel[indexPath.row].author ):  \(dataModel[indexPath.row].description)"
        likesCountLabel.text = dataManager.likeLabelConvert(counter: dataModel[indexPath.row].likesCount)
        likeButton.setImage(UIImage(systemName: dataModel[indexPath.row].isLiked ? "heart.fill" : "heart"), for: .normal)
        likeButton.imageView?.tintColor = .systemPink
        horStackView.distribution = .fillProportionally
        downloadImage(from: URL(string: dataModel[indexPath.row].photoImageUrl)!)
        selectionStyle = .none
        bandImage.clipsToBounds = true
        bandImage.layer.cornerRadius = 15
        bandImage.isUserInteractionEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func downloadImage(from url: URL) {
        networkManager.getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() { [weak self] in
                self?.bandImage.image =  UIImage(data: data)
            }
        }
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return bandImage
        }
    // MARK: - likeButtonPressed
    @objc  func likePressed() {
        likeButtomTap?()
    }
    @objc func didDoubleTapImage(sender: UITapGestureRecognizer)
    {
        likePressed()
    }
    
    
    // MARK: - shareButtonPressed
    //    @objc  func  sharePressed () {
    //        shareButtonTap?()
    //  }
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
            
            scrollView.topAnchor.constraint(equalTo: authorNameLabel.bottomAnchor, constant: 4),
            scrollView.bottomAnchor.constraint(equalTo: horStackView.bottomAnchor, constant: 4),
            scrollView.leadingAnchor.constraint(equalTo: verStackView.leadingAnchor, constant: 0),
            scrollView.trailingAnchor.constraint(equalTo: verStackView.trailingAnchor, constant: 0)
            
            
            
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
            heartImage.leadingAnchor.constraint(equalTo: bandImage.leadingAnchor, constant: 40),
            heartImage.topAnchor.constraint(equalTo: bandImage.topAnchor, constant: 70),
            bandImage.trailingAnchor.constraint(equalTo: heartImage.trailingAnchor, constant: 40),
            bandImage.bottomAnchor.constraint(equalTo: heartImage.bottomAnchor, constant: 70)
        ])
    }
}




