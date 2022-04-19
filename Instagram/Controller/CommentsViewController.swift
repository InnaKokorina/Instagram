//
//  CommentsViewController.swift
//  Instagram
//
//  Created by Inna Kokorina on 06.04.2022.
//

import UIKit

class CommentsViewController: UIViewController {
    
    private var comments = [CommentsModel]()
    var activeTextField : UITextField? = nil
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Comments.plist")
    var selectedImage: DataModel? {
        didSet{
            tableView.reloadData()
        }
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CommentsViewCell.self, forCellReuseIdentifier: "CommentsViewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.setContentHuggingPriority(UILayoutPriority.init(249), for: .vertical)
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
        NotificationCenter.default.addObserver(self, selector: #selector(CommentsViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CommentsViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        print(dataFilePath)
        
        loadComments()
    }
    
    func tableViewsSetup() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }
    
    
}
// MARK: - UITableViewDataSource, UITableViewDelegate
extension CommentsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let newArray = comments.filter { model in
            selectedImage?.author == model.author }
        return newArray.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsViewCell", for: indexPath) as? CommentsViewCell else { return UITableViewCell() }
        let newArray = comments.filter { model in
            selectedImage?.author == model.author
        }
        
        cell.configure(indexPath: indexPath.row, comment: newArray)
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
// MARK: - UITextFieldDelegate
extension CommentsViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = self.textField
        print(activeTextField?.text ?? "nil")
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.activeTextField = self.textField
    }
    
    
    @objc func addCommentTap() {
        textField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if  let message = textField.text {
            let newcomment = CommentsModel(author: selectedImage!.author, comment: message)
            DispatchQueue.main.async { [self] in
                self.comments.append(newcomment)
                self.tableView.reloadData()
                self.saveComments()
                self.textField.text = ""
                self.textField.endEditing(true)
            }
            self.activeTextField = nil
        }
    }
}

// MARK: - keyboardWillShow
extension CommentsViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        var shouldMoveViewUp = false
        if let activeTextField = activeTextField {
            let bottomOfTextField = activeTextField.convert(activeTextField.bounds, to: self.view).maxY;
            let topOfKeyboard = self.view.frame.height - keyboardSize.height
            if bottomOfTextField > topOfKeyboard {
                shouldMoveViewUp = true
            }
            
            
            if shouldMoveViewUp {
                self.view.frame.origin.y = 0 - keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
}

extension CommentsViewController {
    func saveComments() {
        let encoder = PropertyListEncoder()
        do {
            let data =  try encoder.encode(comments)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding item array,\(error)")
        }
        
        self.tableView.reloadData()
    }
    func loadComments() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                comments = try decoder.decode([CommentsModel].self, from: data)
            } catch {
                print("Error dencoding item array,\(error)")
            }
        }
    }
}
