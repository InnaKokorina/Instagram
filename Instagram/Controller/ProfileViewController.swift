//
//  ProfileViewController.swift
//  Instagram
//
//  Created by Inna Kokorina on 20.05.2022.
//

import UIKit

class ProfileViewController: UIViewController {

    var didSetupConstraints = false
    // MARK: - setView
    let headView: UIView = {
        let headView = UIView()
        return headView
    }()
    let personImage: UIImageView = {
        let personImage = UIImageView()
        personImage.image = UIImage(systemName: "person")
        return personImage
    }()
    let userLabel: UILabel = {
        let userLabel = UILabel()
        userLabel.text = "User"
        return userLabel
    }()
    var collectionView: UICollectionView?
//        let collectionView = UICollectionView()
//        collectionView.register(ProfileCollectionViewCell.self, forCellWithReuseIdentifier: ProfileCollectionViewCell.cellId)
//
//        return collectionView
//    }()
// MARK: - lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
      //  layout.itemSize = CGSize(width: view.frame.size.width/3.2, height: view.frame.size.width/3.2)
//        layout.headerReferenceSize = CGSize(width: collectionView.frame.size.width, height: 50)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.register(ProfileCollectionViewCell.self, forCellWithReuseIdentifier: ProfileCollectionViewCell.cellId)
        collectionView?.register(HeaderCollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionViewCell.headerCell)
        view.addSubview(collectionView!)
        view.setNeedsUpdateConstraints()
        collectionView?.delegate = self
        collectionView?.dataSource = self

    }

}
// MARK: - updateViewConstraints
extension ProfileViewController {
    override func updateViewConstraints() {
        if !didSetupConstraints {
//        headView.snp.makeConstraints { make in
//            make.right.left.equalTo(view)
//            make.top.equalTo(view.safeAreaLayoutGuide)
//        }
//        personImage.snp.makeConstraints { make in
//            make.left.equalTo(headView).offset(30)
//            make.top.equalTo(headView).offset(30)
//            make.width.height.equalTo(100)
//        }
            collectionView?.snp.makeConstraints { make in
                make.edges.equalTo(view)
//                make.right.left.equalTo(view)
//                make.bottom.equalTo(view.safeAreaLayoutGuide)
            }
            didSetupConstraints = true
        }
        super.updateViewConstraints()
    }
}
extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? ProfileCollectionViewCell else {return UICollectionViewCell() }
        cell.configure()
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 25
    }

   func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
       guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderCell", for: indexPath) as? HeaderCollectionViewCell else { return UICollectionReusableView() }
       header.configure()
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
