//
//  MainViewController.swift
//  Instagram
//
//  Created by Inna Kokorina on 20.03.2022.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import FirebaseStorage

class MainViewController: UIViewController {
    private var dataManager = DataManager()
    private var dataModel = DataModel(photos: [Photos]())
    private var firebaseManager = FirebaseManager()
    //    private var networkManager = NetworkManager()
    private var activityController: UIActivityViewController? = nil

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MainTableViewCell.self, forCellReuseIdentifier: "MainTableViewCell")
        return tableView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firebaseManager.fetchData()   
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableViewsSetup()
       // networkManager.delegate = self
       //   networkManager.fetchImages(imagesCount: 10)
        firebaseManager.delegate = self
        

        let logOutButton = UIBarButtonItem(title: "Выйти", style: .plain, target: self, action: #selector(logOutButtonPressed))
        self.navigationItem.rightBarButtonItem  = logOutButton
        
        
    }
    
    func tableViewsSetup() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.frame = view.bounds
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.separatorColor = .clear
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(callPullToRefresh), for: .valueChanged)
    }
    // MARK: - RefreshImages
    @objc func callPullToRefresh() {
           firebaseManager.fetchData()
    }
    // MARK: - Logout
    @objc func logOutButtonPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch{
            print(error)
        }
    }
}
// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataModel.photos.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as? MainTableViewCell else { return UITableViewCell() }
        cell.configure(dataModel: dataModel, indexPath: indexPath)
        
        cell.likeButtomTap = {
            self.dataModel.photos[indexPath.row].liked.toggle()
            if self.dataModel.photos[indexPath.row].liked {
                cell.likeButton.imageView?.isHighlighted = true
                cell.likeButton.isSelected = true
                cell.heartView.alpha = 0.5
                let seconds = 0.3
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    cell.heartView.alpha = 0
                }
            } else {
                cell.likeButton.imageView?.isHighlighted = false
                cell.likeButton.isSelected = false
            }
            
            cell.likesCountLabel.text = self.dataManager.likeLabelConvert(counter: self.dataModel.photos[indexPath.row].likes)
        }
        
        //        cell.commentButtonPressed = { [weak self] in
        //            let vc = CommentsViewController()
        //            vc.selectedImage = self?.dataModel[indexPath.row]
        //            self?.navigationController?.pushViewController(vc, animated: true)
        //        }
        return cell
    }
}
// MARK: - FirebaseManagerDelegate

extension MainViewController : FirebaseManagerDelegate {

    func didUpdateImages(_ firebaseManager:FirebaseManager, image: DataModel) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.dataModel = image
            print("DATA MODEL: \(self.dataModel)")
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
}


// MARK: - NetworkManagerDelegate

//extension MainViewController : NetworkManagerDelegate {
//
//    func didUpdateImages(_ networkManager:NetworkManager, image: [DataModel]) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
//            self.dataModel = image + self.dataModel
//            self.tableView.refreshControl?.endRefreshing()
//            self.tableView.reloadData()
//        }
//    }
//
//    func didFailWithError() {
//        print("ошибка сети")
//    }
//}

