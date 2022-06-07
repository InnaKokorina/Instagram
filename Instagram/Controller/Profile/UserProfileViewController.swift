//
//  UserProfileViewController.swift
//  Instagram
//
//  Created by Inna Kokorina on 20.05.2022.
//

import UIKit
import Firebase

class UserProfileViewController: UIViewController, TabBarDelegate {

    var didSetupConstraints = false
    // MARK: - setView
    var posts = [Posts]()
    var collectionView: UICollectionView?
    private var user = Auth.auth().currentUser?.email as? String

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
    }
    func transferModelData(data: [Posts]) {
//        print("data.count = \(data.count)")
        for post in data {
            let id = user?.userId
            if id ==  post.user.userId {
                posts.append(post)
            }
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
        if posts.count == 0 {
            return 1
        }
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if posts.count == 0 {
           guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userProfileNoPostsCellId", for: indexPath) as? UserProfileNoPostsCell else {return UICollectionViewCell()}
            return cell
        } else {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? UserProfileCollectionCell else {return UICollectionViewCell() }
        cell.configure(post: posts[indexPath.row])
        return cell
        }
    }

   func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
       guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderCell", for: indexPath) as? UserProfileHeaderCell else { return UICollectionReusableView() }
       header.personImage.image = UIImage(systemName: "person")
       header.userLabel.text = user
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
