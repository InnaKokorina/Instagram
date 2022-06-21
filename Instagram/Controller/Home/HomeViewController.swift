//
//  HomeViewController.swift
//  Instagram
//
//  Created by Inna Kokorina on 20.03.2022.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import FirebaseStorage
import RealmSwift

class HomeViewController: UIViewController {
    private var dataModel: Results<PostsRealm>?
    private var activityController: UIActivityViewController?
    private var ref: DatabaseReference!
    private let realm = try! Realm()
    private let spinner = SpinnerViewController()
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.separatorColor = .clear
        return tableView
    }()
    private let spinnerImage: UIImageView = {
        let image = UIImageView()
        return image
    }()
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavItems()
        view.addSubview(spinnerImage)
        spinnerImage.frame = view.bounds
        spinnerImage.isHidden = true
        spinner.start(view: spinnerImage)
        if realm.isEmpty {
            spinnerImage.isHidden = false
            FirebaseManager.shared.fetchData { post in
                do {
                    try self.realm.write({
                        self.realm.add(post)
                    })
                } catch {
                    print("Error saving Data context \(error)")
                }
                // load from Realm
                DispatchQueue.main.async {
                    self.spinner.stop()
                    self.tableViewsSetup()
                    self.spinnerImage.isHidden = true
                    print("loadPosts \(post)")
                    self.loadPosts()
                }
            }
        } else {
            DispatchQueue.main.async {
                self.spinnerImage.isHidden = true
                self.tableViewsSetup()
                self.loadPosts()
            }
        }
    }
    // MARK: - tableViewSetup
    func tableViewsSetup() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(callPullToRefresh), for: .valueChanged)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    // MARK: - navigationItems
    func setupNavItems() {
        let logOutButton = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logOutButtonPressed))
        logOutButton.tintColor = .black
        let addPhoto = UIBarButtonItem(image: UIImage(systemName: "plus.app"), style: .plain, target: self, action: #selector(addNewPost))
        addPhoto.tintColor = .black
        navigationItem.rightBarButtonItem  = logOutButton
        navigationItem.leftBarButtonItem = addPhoto
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
    @objc func addNewPost(_ sender: Any) {
        let viewController = NewPhotoViewController()
        viewController.dataModel = self.dataModel
        navigationController?.pushViewController(viewController, animated: true)
    }
    // MARK: - RefreshImages
    @objc func callPullToRefresh() {
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
            self.loadPosts()
        }
    }
    // MARK: - loadPosts from Realm
    func loadPosts () {
        dataModel = realm.objects(PostsRealm.self).sorted(byKeyPath: "id", ascending: false)
      //  DispatchQueue.main.async {
            tableView.reloadData()
      //  }
    }
}
// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataModel?.count != 0 {
            return dataModel!.count
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.identifier, for: indexPath) as? HomeTableViewCell else { return UITableViewCell() }
        if let posts = self.dataModel {
            cell.configure(dataModel: posts[indexPath.row])
            // set like
            cell.likeButtomTap = {
                var newLikedUser = LikedByUsers()
                        do {
                            try self.realm.write {
                                posts[indexPath.row].liked.toggle()
                                if DataManager.shared.likedByUser(currentUserId: Auth.auth().currentUser!.uid, usersArray: posts[indexPath.row].likedByUsers) == false {
                                    posts[indexPath.row].liked = true
                                    cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                                    posts[indexPath.row].likes += 1
                                    newLikedUser = LikedByUsers(userId: Auth.auth().currentUser!.uid)
                                    posts[indexPath.row].likedByUsers.append(newLikedUser)
                                    cell.heartView.alpha = 0.5
                                    let seconds = 0.3
                                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                        cell.heartView.alpha = 0
                                    }
                                    self.ref = Database.database().reference().child("photos/\(posts[indexPath.row].id)/likedByUsers/\(posts[indexPath.row].likedByUsers.count - 1)")
                                    let  dictUser = ["userId": newLikedUser.userId]
                                    as [String: Any]
                                    self.ref.updateChildValues(dictUser)
                                } else {
                                    cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                                    posts[indexPath.row].liked = false
                                    posts[indexPath.row].likes -= 1
                                    self.realm.delete(posts[indexPath.row].likedByUsers.filter("userId=%@", Auth.auth().currentUser!.uid))
                                    self.ref = Database.database().reference().child("photos/\(posts[indexPath.row].id)/likedByUsers/\(posts[indexPath.row].likedByUsers.count)")
                                    let  dictUser = ["userId": newLikedUser.userId]
                                    as [String: Any]
                                    self.ref.updateChildValues(dictUser) }
                                cell.likesCountLabel.text = DataManager.shared.likeLabelConvert(counter: posts[indexPath.row].likes)
                                self.ref = Database.database().reference().child("photos/\(posts[indexPath.row].id)")
                                let  dict = [
                                    "liked": posts[indexPath.row].liked,
                                    "likes": posts[indexPath.row].likes
                                ]
                                as [String: Any]
                                self.ref.updateChildValues(dict)
                            }
                        } catch {
                            print("Error saving Data context \(error)")
                        }
                }
                cell.deleteButton.isHidden = true
                // navigation to comments
                cell.commentButtonPressed = { [unowned self] in
                    let viewController = CommentsViewController()
                    viewController.selectedImage = dataModel![indexPath.row]
                    navigationController?.pushViewController(viewController, animated: true)
                }
                cell.locationPressed  = {
                    if cell.locationButton.currentTitle! != "" {
                        let mapVC = MapViewController()
                        mapVC.searchPoint = cell.locationButton.currentTitle!
                        self.navigationController?.pushViewController(mapVC, animated: true)
                    }
                }
                cell.authorLabelPressed = {
                    let users = self.realm.objects(UserRealm.self)
                    var user = UserRealm()
                    let userProfileController = UserProfileViewController()
                    for eachUser in users where eachUser.userId == posts[indexPath.row].user?.userId {
                        user = eachUser }
                    userProfileController.user = user
                    self.navigationController?.pushViewController(userProfileController, animated: true)
                }
            }
        return cell
    }
}
