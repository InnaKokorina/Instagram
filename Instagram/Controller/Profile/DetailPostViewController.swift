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
        var postStruct = [Posts]()
        postStruct.append(DataManager.shared.tranferModeltoStruct(withPhoto: post!))
            // set like
        cell.likeButtomTap = {
                do {
                    try self.realm.write {
                        let postsRealm: Results<PostsRealm>?
                        postsRealm = self.realm.objects(PostsRealm.self)
                        for index in 0..<postsRealm!.count { /// unwrap
                            if postStruct[indexPath.row].id == postsRealm![index].id {
                                postStruct[indexPath.row].liked.toggle()
                                postsRealm![index].liked.toggle()
                        if postStruct[indexPath.row].liked == true {
                            cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                            postStruct[indexPath.row].likes += 1
                            postsRealm![index].likes += 1
                            cell.heartView.alpha = 0.5
                            let seconds = 0.3
                            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                cell.heartView.alpha = 0
                            }
                        } else {
                            cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                            postStruct[indexPath.row].likes -= 1
                           postsRealm![index].likes -= 1
                        }

                                cell.likesCountLabel.text = DataManager.shared.likeLabelConvert(counter: postStruct[indexPath.row].likes)
                                self.ref = Database.database().reference().child("photos/\(postsRealm![index].id)")
                                let dict = ["liked": postsRealm![index].liked, "likes": postsRealm![index].likes] as [String: Any]
                                self.ref.updateChildValues(dict)
                            }
                        }
                    }
                } catch {
                    print("Error saving Data context \(error)")
              }
            }
        var posts = [PostsRealm]()
        posts.append(post!)
        cell.configure(dataModel: postStruct, indexPath: indexPath)
            // navigation to comments
            cell.commentButtonPressed = { [unowned self] in
                let viewController = CommentsViewController()
                viewController.selectedImage = posts[indexPath.row]
                navigationController?.pushViewController(viewController, animated: true)
        }
        return cell
    }
}
