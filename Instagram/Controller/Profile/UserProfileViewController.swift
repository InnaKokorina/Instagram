//
//  UserProfileViewController.swift
//  Instagram
//
//  Created by Inna Kokorina on 20.05.2022.
//

import UIKit
import Firebase
import RealmSwift

class UserProfileViewController: UIViewController {
    var didSetupConstraints = false
    // MARK: - setView
    var posts: Results<PostsRealm>?
    var currentPosts = [PostsRealm]()
    var collectionView: UICollectionView?
    private let realm = try! Realm()
    var user: UserRealm? {
        didSet {
           loadPosts()
        }
    }
// MARK: - lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.register(UserProfileCollectionCell.self, forCellWithReuseIdentifier: UserProfileCollectionCell.cellId)
        collectionView?.register(UserProfileNoPostsCell.self, forCellWithReuseIdentifier: UserProfileNoPostsCell.cellId)
        collectionView?.register(UserProfileHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UserProfileHeaderCell.headerCell)
        view.addSubview(collectionView!)
        view.setNeedsUpdateConstraints()
        collectionView?.delegate = self
        collectionView?.dataSource = self
        setupNavItems()
        chooseUser()
        collectionView?.refreshControl = UIRefreshControl()
        collectionView?.refreshControl?.addTarget(self, action: #selector(callPullToRefresh), for: .valueChanged)
    }

    func loadPosts() {
        currentPosts = []
        posts = realm.objects(PostsRealm.self)
        if posts != nil {
            for post in posts! where post.user?.userId == user?.userId {
                let onePost = post
                currentPosts.append(onePost)
            }
        }
    }
    func chooseUser() {
        if user == nil {
            let allUsers = self.realm.objects(UserRealm.self)
            for eachUser in allUsers where eachUser.userId == Auth.auth().currentUser!.uid {
                user = eachUser
            }
            navigationItem.leftBarButtonItem?.tintColor = .clear
        }
    }

    // MARK: - navigationItems
    func setupNavItems() {
        let logOutButton = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logOutButtonPressed))
        logOutButton.tintColor = .black
        navigationItem.rightBarButtonItem  = logOutButton
        navigationItem.title = user?.userName
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
    // MARK: - RefreshImages
    @objc func callPullToRefresh() {
        DispatchQueue.main.async { [self] in
            collectionView?.refreshControl?.endRefreshing()
            self.loadPosts()
            collectionView?.reloadData()
        }
    }
}
// MARK: - updateViewConstraints
extension UserProfileViewController {
    override func updateViewConstraints() {
        if !didSetupConstraints {
            collectionView?.snp.makeConstraints { make in
                make.edges.equalTo(view)
            }
            didSetupConstraints = true
        }
        super.updateViewConstraints()
    }
}
extension UserProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if currentPosts.count == 0 {
            return 1
        }
        return currentPosts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if currentPosts.count == 0 {
           guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userProfileNoPostsCellId", for: indexPath) as? UserProfileNoPostsCell else {return UICollectionViewCell()}
            return cell
        } else {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? UserProfileCollectionCell else {return UICollectionViewCell() }
        cell.configure(post: currentPosts[indexPath.row])
        return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = DetailPostViewController()
        if currentPosts.count != 0 {
        detailVC.post = currentPosts[indexPath.row]
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }

   func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
       guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderCell", for: indexPath) as? UserProfileHeaderCell else { return UICollectionReusableView() }
       header.personImage.image = FirebaseManager.shared.setImage(data: user?.userPhoto)
       header.userLabel.text = user?.userName
       return header

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
}
