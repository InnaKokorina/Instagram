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

class CommentsViewController: UIViewController {
    
    private var auth = AuthorizationViewController()
    var activeTextField : UITextField? = nil
    private var firebaseManager = FirebaseManager()
    private var ref: DatabaseReference!
    
    
//    var selectedImage = Photos(comment: [CommentsModel]())
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firebaseManager.fetchData()
    }
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        horStackView.backgroundColor = .systemIndigo
        tableViewsSetup()
        view.addSubview(horStackView)
        setConstraints()
        textField.delegate = self
        // firebaseManager.delegate = self
        addComment.addTarget(self, action: #selector(addCommentTap), for: .touchUpInside)
        setupNavItems()
        // keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(CommentsViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CommentsViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    
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
        self.navigationItem.rightBarButtonItem  = logOutButton
        let back = UIBarButtonItem(image: UIImage(systemName: "chevron.compact.left"), style: .plain, target: self, action: #selector(backPressed))
        back.tintColor = .black
        self.navigationItem.leftBarButtonItem = back
    }
    
    @objc func backPressed() {
        let vc = MainViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func logOutButtonPressed(_ sender: Any) {
        do{
            try Auth.auth().signOut()
        }catch{
            print(error)
        }
    }
    
    
}
// MARK: - UITableViewDataSource, UITableViewDelegate
extension CommentsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
  //      return selectedImage.comment.count
        
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsViewCell", for: indexPath) as? CommentsViewCell else { return UITableViewCell() }
   //     cell.configure(indexPath: indexPath.row, comment: selectedImage.comment)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
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
            let email  = auth.setName()
  //          let id = selectedImage.comment.count
  //          let postId = selectedImage.id
          //  let newcomment = CommentsModel(body: message, email: email, id: id, postId: postId)
          //  selectedImage.comment.append(newcomment)
            
            // save to FB
     //       self.ref =  Database.database().reference().child("photos/\(postId)/comments/\(id)")
        //    let dictionary = ["email": newcomment.email,"body": newcomment.body,"id": newcomment.id,"postId": newcomment.postId] as [String : Any]
         //   ref.setValue(dictionary)
            tableView.reloadData()
            self.textField.text = ""
            self.textField.endEditing(true)
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

// MARK: - FirebaseManagerDelegate

//extension CommentsViewController : FirebaseManagerDelegate {
//
//    func didUpdateImages(_ firebaseManager: FirebaseManager, image: DataModel) {
//        DispatchQueue.main.async {
//            self.dataModel.photos = image.photos.reversed() + self.dataModel.photos
//            self.tableView.refreshControl?.endRefreshing()
//            self.tableView.reloadData()
//        }
//    }
//
//    func didUpdateComments(_ firebaseManager: FirebaseManager, comment: [CommentsModel]) {
//        DispatchQueue.main.async() {
//            self.comments = comment
//            self.tableView.reloadData()
//        }
//    }
//}
