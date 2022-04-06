//
//  CommentsViewController.swift
//  Instagram
//
//  Created by Inna Kokorina on 06.04.2022.
//

import UIKit

class CommentsViewController: UIViewController {
    
    private var comments = [CommentsModel]()
    var selectedImage: DataModel? {
        didSet{
            tableView.reloadData()
        }
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CommentsViewCell.self, forCellReuseIdentifier: "CommentsViewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Введите комментарий"
        textField.backgroundColor = .white
        textField.borderStyle = .roundedRect
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 14
        textField.viewWithTag(0)
        return textField
    }()
    
    private let addComment: UIButton = {
        let addComment = UIButton()
        addComment.translatesAutoresizingMaskIntoConstraints = false
        addComment.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        addComment.imageView?.tintColor = .white
        return addComment
    }()
    
    private lazy var horStackView = UIStackView(arrangedSubviews: [textField, addComment], axis: .horizontal, spacing: 4)
    
    override func viewDidLoad() {
        
        view.backgroundColor = .systemBackground
        horStackView.backgroundColor = .systemIndigo
        tableViewsSetup()
        view.addSubview(horStackView)
        setConstraints()
        textField.delegate = self
        addComment.addTarget(self, action: #selector(addCommentTap), for: .touchUpInside)
    }
    
    func tableViewsSetup() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.separatorStyle = .singleLine
        tableView.allowsSelection = true
        tableView.separatorColor = .clear
        
    }
    
    @objc func addCommentTap() {
    if  let message = textField.text {
        let newcomment = CommentsModel(author: selectedImage!.author, comment: message)
        DispatchQueue.main.async {
            self.comments.append(newcomment)
            self.tableView.reloadData()
        }
        
    }
        }
}

extension CommentsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsViewCell", for: indexPath) as? CommentsViewCell else { return UITableViewCell() }
        cell.configure(indexPath: indexPath, comment: comments)
        
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: 0),
            
            
            horStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            horStackView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 0),
            view.trailingAnchor.constraint(equalTo: horStackView.trailingAnchor, constant: 0),
            view.bottomAnchor.constraint(equalTo: horStackView.bottomAnchor, constant: 0),
            
            textField.leadingAnchor.constraint(equalTo: horStackView.leadingAnchor, constant: 20),
            textField.topAnchor.constraint(equalTo: horStackView.topAnchor, constant: 20),
            view.trailingAnchor.constraint(equalTo: addComment.trailingAnchor, constant: 20),
            view.bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            
            
            horStackView.heightAnchor.constraint(equalToConstant: 100),
            addComment.widthAnchor.constraint(equalToConstant: 30)
            
        ])
    }
}

extension CommentsViewController: UITextFieldDelegate {
    
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "type a message"
            return false
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = ""
    }
}
