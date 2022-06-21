//
//  DetailPostViewController.swift
//  Instagram
//
//  Created by Inna Kokorina on 10.06.2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import RealmSwift

class DetailPostViewController: UIViewController {
    private var ref: DatabaseReference!
    private let realm = try! Realm()
    var post: PostsRealm? {
        didSet {
        }
    }
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "HomeTableViewCell")
        return tableView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableViewsSetup()
        setupNavItems()
    }
    // MARK: - tableViewSetup
    func tableViewsSetup() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    // MARK: - navigationItems
    func setupNavItems() {
        let logOutButton = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logOutButtonPressed))
        logOutButton.tintColor = .black
        navigationItem.rightBarButtonItem  = logOutButton
        navigationItem.title = Constants.App.title
        let back = UIBarButtonItem(image: UIImage(systemName: "chevron.compact.left"), style: .plain, target: self, action: #selector(backPressed))
        back.tintColor = .black
        navigationItem.leftBarButtonItem = back
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

extension DetailPostViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell", for: indexPath) as? HomeTableViewCell else { return UITableViewCell() }
        if let post = self.post {
            cell.configure(dataModel: post)
            cell.likeButtomTap = {
                var newLikedUser = LikedByUsers()
                        do {
                            try self.realm.write {
                                post.liked.toggle()
                                if DataManager.shared.likedByUser(currentUserId: Auth.auth().currentUser!.uid, usersArray: post.likedByUsers) == false {
                                    post.liked = true
                                    cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                                    post.likes += 1
                                    newLikedUser = LikedByUsers(userId: Auth.auth().currentUser!.uid)
                                    post.likedByUsers.append(newLikedUser)
                                    cell.heartView.alpha = 0.5
                                    let seconds = 0.3
                                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                        cell.heartView.alpha = 0
                                    }
                                    self.ref = Database.database().reference().child("photos/\(post.id)/likedByUsers/\(post.likedByUsers.count - 1)")
                                    let  dictUser = ["userId": newLikedUser.userId]
                                    as [String: Any]
                                    self.ref.updateChildValues(dictUser)
                                } else {
                                    cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                                    post.liked = false
                                    post.likes -= 1
                                    self.realm.delete(post.likedByUsers.filter("userId=%@", Auth.auth().currentUser!.uid))
                                    self.ref = Database.database().reference().child("photos/\(post.id)/likedByUsers/\(post.likedByUsers.count)")
                                    let  dictUser = ["userId": newLikedUser.userId]
                                    as [String: Any]
                                    self.ref.updateChildValues(dictUser) }
                                cell.likesCountLabel.text = DataManager.shared.likeLabelConvert(counter: post.likes)
                                self.ref = Database.database().reference().child("photos/\(post.id)")
                                let  dict = [
                                    "liked": post.liked,
                                    "likes": post.likes
                                ]
                                as [String: Any]
                                self.ref.updateChildValues(dict)
                            }
                        } catch {
                            print("Error saving Data context \(error)")
                        }
                }
            // navigation to comments
            cell.commentButtonPressed = { [unowned self] in
                let viewController = CommentsViewController()
                viewController.selectedImage = post
                navigationController?.pushViewController(viewController, animated: true)
        }
        cell.locationPressed  = {
            if cell.locationButton.currentTitle! != "" {
            let mapVC = MapViewController()
            mapVC.searchPoint = cell.locationButton.currentTitle!
            self.navigationController?.pushViewController(mapVC, animated: true)
            }
        }
        cell.deleteItem = {
            let alert = UIAlertController(title: "", message: "Удалить фото?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        do {
                            try self.realm.write {
                                self.ref = Database.database().reference().child("photos/\(post.id)")
                                self.ref.removeValue()
                                self.realm.delete(post)
                            }
                        } catch {
                            print("error in deleting category \(error)")
                        }
                self.navigationController?.popViewController(animated: true)
            }
            )
            alert.addAction(UIAlertAction(title: "Oтмена", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        }
        return cell
    }
}
