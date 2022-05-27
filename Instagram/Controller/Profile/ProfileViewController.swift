//
//  ProfileViewController.swift
//  Instagram
//
//  Created by Inna Kokorina on 20.05.2022.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, TabBarDelegate {

    var didSetupConstraints = false
    // MARK: - setView
    var posts = [Posts]()
    var collectionView: UICollectionView?


// MARK: - lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.register(ProfileCollectionViewCell.self, forCellWithReuseIdentifier: ProfileCollectionViewCell.cellId)
        collectionView?.register(HeaderCollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionViewCell.headerCell)
        view.addSubview(collectionView!)
        view.setNeedsUpdateConstraints()
        collectionView?.delegate = self
        collectionView?.dataSource = self   
    }
    
    func transferModelData(data: [Posts]) {
        print("data.count = \(data.count)")
        for post in data {
            let name = Auth.auth().currentUser?.email as? String
            if name ==  post.user {
                posts.append(post)
            }
        }
    }
}
// MARK: - updateViewConstraints
extension ProfileViewController {
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
extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? ProfileCollectionViewCell else {return UICollectionViewCell() }
        cell.configure(post: posts[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

   func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
       guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderCell", for: indexPath) as? HeaderCollectionViewCell else { return UICollectionReusableView() }
       header.personImage.image = UIImage(systemName: "person")
       header.userLabel.text = posts[0].user
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
