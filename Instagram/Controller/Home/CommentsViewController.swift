//
//  CommentsViewController.swift
//  Instagram
//
//  Created by Inna Kokorina on 06.04.2022.
//

import UIKit
import FirebaseAuth
import RealmSwift
import SnapKit

class CommentsViewController: UIViewController {
    private var didSetupConstraints = false
    private var activeTextField: UITextField?
    private var comments: Results<CommentsRealm>?
    private let realm = try! Realm()
    var selectedImage: PostsRealm? {
        didSet {
            loadComments()
        }
    }
    // MARK: - View
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CommentsViewCell.self, forCellReuseIdentifier: "CommentsViewCell")
        tableView.setContentHuggingPriority(UILayoutPriority.init(249), for: .vertical)
        return tableView
    }()

    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите комментарий"
        textField.backgroundColor = .white
        textField.backgroundColor = .white
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 8
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 14
        textField.viewWithTag(0)
        return textField
    }()
    private let addComment: UIButton = {
        let addComment = UIButton()
        addComment.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        addComment.imageView?.tintColor = .black
        return addComment
    }()
    private lazy var horStackView = UIStackView(arrangedSubviews: [textField, addComment], axis: .horizontal, spacing: 8)
    // MARK: - lifecycle
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        tableViewsSetup()
        view.addSubview(horStackView)
        view.setNeedsUpdateConstraints()
        textField.delegate = self
        addComment.addTarget(self, action: #selector(addCommentTap), for: .touchUpInside)
        setupNavItems()
    }
    // MARK: - tableViewsSetup()
    func tableViewsSetup() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }
    // MARK: - loadComments()
    func loadComments() {
        comments = selectedImage?.comment.sorted(byKeyPath: "id", ascending: true)
        tableView.reloadData()
    }
}
// MARK: - UITableViewDataSource, UITableViewDelegate
extension CommentsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments?.count ?? 1

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsViewCell", for: indexPath) as? CommentsViewCell else { return UITableViewCell() }
        if let comments = comments {
            cell.configure(indexPath: indexPath.row, comment: comments)
        }
        return cell
    }
}
// MARK: - UITextFieldDelegate
extension CommentsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @objc func addCommentTap() {
        let users = realm.objects(UserRealm.self)
        var currentUser: UserRealm?
        for eachUser in users where eachUser.userId == Auth.auth().currentUser?.uid {
            currentUser = eachUser
        }
     if let currentImage = self.selectedImage {
            if  let message = textField.text {
                FirebaseManager.shared.saveComment(message: message, currentImage: currentImage, currentUser: currentUser!.userName)
                tableView.reloadData()
                textField.text = ""
                textField.endEditing(true)
            }
        }
    }
}
// MARK: - keyboardWillShow
extension CommentsViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        var shouldMoveViewUp = false
        if let activeTextField = activeTextField {
            let bottomOfTextField = activeTextField.convert(activeTextField.bounds, to: self.view).maxY
            let topOfKeyboard = self.view.frame.height - keyboardSize.height
            if bottomOfTextField > topOfKeyboard {
                shouldMoveViewUp = true
            }
            if shouldMoveViewUp {
                self.view.frame.origin.y = 0 - keyboardSize.height
            }
        }
    }
}
    // MARK: - setConstraints()
extension CommentsViewController {
    override func updateViewConstraints() {
        if !didSetupConstraints {
            tableView.snp.makeConstraints { make in
                make.left.right.equalTo(view)
                make.top.equalTo(view).offset(10)
            }
            horStackView.snp.makeConstraints { make in
                make.left.right.equalTo(view)
                make.bottom.equalTo(view)
                make.top.equalTo(tableView.snp.bottom)
                make.height.equalTo(50)
            }
            addComment.snp.makeConstraints { make in
                make.top.equalTo(horStackView)
                make.right.equalTo(horStackView)
                make.bottom.equalTo(horStackView.snp.bottom)
                make.width.equalTo(40)
            }
            textField.snp.makeConstraints { make in
                make.top.equalTo(horStackView)
                make.left.equalTo(horStackView).offset(10)
                make.bottom.equalTo(view.safeAreaLayoutGuide)
            }
            didSetupConstraints = true
        }
        super.updateViewConstraints()
    }
 }
// MARK: - NavigationItems
extension CommentsViewController {
    func setupNavItems() {
        let logOutButton = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logOutButtonPressed))
        navigationItem.rightBarButtonItem  = logOutButton
        logOutButton.tintColor = .black
        let back = UIBarButtonItem(image: UIImage(systemName: "chevron.compact.left"), style: .plain, target: self, action: #selector(backPressed))
        back.tintColor = .black
        navigationItem.leftBarButtonItem = back
        navigationItem.title = Constants.App.titleComments
    }
    @objc func backPressed() {
        navigationController?.popViewController(animated: true)
    }
    @objc func logOutButtonPressed(_ sender: Any) {
        do {
            navigationController?.popViewController(animated: true)
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
    }
}
