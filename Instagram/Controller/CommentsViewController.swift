//
//  CommentsViewController.swift
//  Instagram
//
//  Created by Inna Kokorina on 06.04.2022.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import FirebaseStorage
import RealmSwift
import SnapKit

class CommentsViewController: UIViewController {
    var didSetupConstraints = false
    private var auth = AuthorizationViewController()
    var activeTextField: UITextField?
    private var firebaseManager = FirebaseManager()
    private var ref: DatabaseReference!
    private let realm = try! Realm()
    private var comments: Results<CommentsModel>?

    var selectedImage: Photos? {
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
        textField.borderStyle = .roundedRect
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 14
        textField.viewWithTag(0)
        return textField
    }()

    private let addComment: UIButton = {
        let addComment = UIButton()
        addComment.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        addComment.imageView?.tintColor = .white
        return addComment
    }()

    private lazy var horStackView = UIStackView(arrangedSubviews: [textField, addComment], axis: .horizontal, spacing: 8)
    // MARK: - lifecycle
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        horStackView.backgroundColor = UIColor(red: 0.25, green: 0.16, blue: 0.58, alpha: 1)
        tableViewsSetup()
        view.addSubview(horStackView)
      //  horStackView.layer.borderColor  = CGColor(red: 0.25, green: 0.16, blue: 0.58, alpha: 1)
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
    // MARK: - NavigationItems
    func setupNavItems() {
        let logOutButton = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logOutButtonPressed))
        navigationItem.rightBarButtonItem  = logOutButton
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    // MARK: - setConstraints()
    override func updateViewConstraints() {
        if !didSetupConstraints {
            tableView.snp.makeConstraints { make in
                make.left.right.top.equalTo(view)
            }
            horStackView.snp.makeConstraints { make in
                make.left.right.equalTo(view)
                make.bottom.equalTo(view)
                make.top.equalTo(tableView.snp.bottom)
                make.height.equalTo(70)
            }
            addComment.snp.makeConstraints { make in
                make.top.equalTo(horStackView).offset(1)
                make.right.equalTo(horStackView).offset(1)
                make.bottom.equalTo(horStackView.snp.bottom).offset(1)
                make.width.equalTo(40)
            }
            textField.snp.makeConstraints { make in
                make.top.left.equalTo(horStackView).inset(1)
                make.bottom.equalTo(view.safeAreaLayoutGuide).inset(1)
            }
            didSetupConstraints = true
        }
        super.updateViewConstraints()
    }
 }

// MARK: - UITextFieldDelegate
extension CommentsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc func addCommentTap() {
     if let currentImage = self.selectedImage {
            if  let message = textField.text {
                let email  = auth.setName()
                let id = currentImage.comment.count
                let postId = currentImage.id
                do {
                    try realm.write {
                        let newcomment = CommentsModel(body: message, email: email, id: id, postId: postId)
                        currentImage.comment.append(newcomment)
                        self.ref =  Database.database().reference().child("photos/\(postId)/comments/\(id)")
                        let dictionary = ["email": newcomment.email, "body": newcomment.body, "id": newcomment.id, "postId": newcomment.postId] as [String: Any]
                        ref.setValue(dictionary)
                    }
                } catch {
                    print("Error saving Data context \(error)")
                }
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
