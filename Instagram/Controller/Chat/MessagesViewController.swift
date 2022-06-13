//
//  MessagesViewController.swift
//  Instagram
//
//  Created by Inna Kokorina on 09.06.2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class MessagesViewController: UIViewController {
    private var didSetupConstraints = false
    private var activeTextField: UITextField?
    let dataBase = Firestore.firestore()
    var partner: UserRealm? {
        didSet {
            loadMessages()
        }
    }
    var messages = [Messages]()
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MessagesViewCell.self, forCellReuseIdentifier: "MessagesViewCell")
        tableView.setContentHuggingPriority(UILayoutPriority.init(249), for: .vertical)
        return tableView
    }()

    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите сообщение"
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

    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        tableViewsSetup()
        view.addSubview(horStackView)
        view.setNeedsUpdateConstraints()
        textField.delegate = self
        addComment.addTarget(self, action: #selector(addMessageTap), for: .touchUpInside)
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
    func loadMessages() {
        dataBase.collection(Constants.FStore.collectionName).order(by: Constants.FStore.dateField).addSnapshotListener { [self] querySnapshot, error in
            self.messages = []
            if let error = error {
                print(" error during loadint data from farestire db \(error)")
            } else {
                if let snapshot = querySnapshot?.documents {
                    for doc in snapshot {
                        let data = doc.data()
                        if let user = data[Constants.FStore.user] as? String,
                           let partner = data[Constants.FStore.partner] as? String,
                           let body = data[Constants.FStore.bodyField] as? String {
                            let newMessage = Messages(user: user, partner: partner, body: body)
                            if newMessage.partner == self.partner?.userEmail && newMessage.user == Auth.auth().currentUser!.email || newMessage.partner == Auth.auth().currentUser!.email && newMessage.user == self.partner?.userEmail {
                            self.messages.append(newMessage)
                            }
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                if self.messages.count != 0 {
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    // MARK: - NavigationItems
    func setupNavItems() {
        let logOutButton = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logOutButtonPressed))
        navigationItem.rightBarButtonItem  = logOutButton
        navigationItem.rightBarButtonItem?.tintColor = .black
        let back = UIBarButtonItem(image: UIImage(systemName: "chevron.compact.left"), style: .plain, target: self, action: #selector(backPressed))
        back.tintColor = .black
        navigationItem.leftBarButtonItem = back
        navigationItem.title = partner?.userName
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
// MARK: - UITableViewDataSource, UITableViewDelegate
extension MessagesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessagesViewCell", for: indexPath) as? MessagesViewCell else { return UITableViewCell() }
        cell.messageLabel.text = messages[indexPath.row].body
        // this is the message from current user
        if message.user == Auth.auth().currentUser?.email {
            cell.rightUserLabel.isHidden = true
            cell.leftUserLabel.isHidden = false
            cell.messageView.backgroundColor = UIColor(red: 0.90, green: 0.81, blue: 1, alpha: 1)
        }
       // this is the message from another user
        else {
            cell.rightUserLabel.isHidden = false
            cell.leftUserLabel.isHidden = true
            cell.messageView.backgroundColor = UIColor(red: 0.70, green: 0.81, blue: 1, alpha: 1)

        }
        return cell
    }
}
  // MARK: - updateViewConstraints()
extension MessagesViewController {
    override func updateViewConstraints() {
        if !didSetupConstraints {
            tableView.snp.makeConstraints { make in
                make.left.right.top.equalTo(view)
            }
            horStackView.snp.makeConstraints { make in
                make.right.equalTo(view)
                make.left.equalTo(view).offset(10)
                make.bottom.equalTo(view)
                make.top.equalTo(tableView.snp.bottom)
                make.height.equalTo(50)
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
extension MessagesViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc func addMessageTap() {
        if let messageBody = textField.text, let messageSender = Auth.auth().currentUser?.email {
            dataBase.collection(Constants.FStore.collectionName).addDocument(data: [
                Constants.FStore.bodyField: messageBody,
                Constants.FStore.user: messageSender,
                Constants.FStore.partner: partner?.userEmail as Any,
                Constants.FStore.dateField: Date.timeIntervalSinceReferenceDate]) { error in
                if let error = error {
                    print(" error during saving data to farestire db \(error)")
                } else {
                    print("successfully saved data to Firestore")
                    DispatchQueue.main.async {
                    self.textField.text = ""
                    }
                }
            }
        }

    }
}

// MARK: - keyboardWillShow
extension MessagesViewController {
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
