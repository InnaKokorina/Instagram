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
    private var activityController: UIActivityViewController? = nil
    private var ref: DatabaseReference!
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MainTableViewCell.self, forCellReuseIdentifier: "MainTableViewCell")
        return tableView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableViewsSetup()
        firebaseManager.delegate = self
        firebaseManager.fetchData()
        
        
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
//        tableView.refreshControl?.addTarget(self, action: #selector(callPullToRefresh), for: .valueChanged)
    }
    // MARK: - RefreshImages
//    @objc func callPullToRefresh() {
//        firebaseManager.fetchData()
//    }
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
        
            if self.dataModel.photos[indexPath.row].liked == true {
                self.dataModel.photos[indexPath.row].likes += 1
                
                cell.heartView.alpha = 0.5
                let seconds = 0.3
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    cell.heartView.alpha = 0
                }
                cell.configure(dataModel: self.dataModel, indexPath: indexPath)
            } else if self.dataModel.photos[indexPath.row].liked == false {
                self.dataModel.photos[indexPath.row].likes -= 1
                cell.configure(dataModel: self.dataModel, indexPath: indexPath)
            }

            
            
            
            // update DB

            let  liked = ["liked": self.dataModel.photos[indexPath.row].liked]
            let  likes = ["likes": self.dataModel.photos[indexPath.row].likes]
            self.ref.updateChildValues(liked)
            self.ref.updateChildValues(likes)
        }
        
        cell.commentButtonPressed = { [weak self] in
            let vc = CommentsViewController()
            vc.selectedImage = self?.dataModel.photos[indexPath.row]
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        return cell
    }
}
// MARK: - FirebaseManagerDelegate

extension MainViewController : FirebaseManagerDelegate {
    func didUpdateComments(_ firebaseManager: FirebaseManager, comment: [CommentsModel]) {
        
    }
    
    
    func didUpdateImages(_ firebaseManager:FirebaseManager, image: DataModel) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.dataModel = image
         //   self.tableView.refreshControl?.endRefreshing()
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

