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
        navigationItem.title = Constants.App.title
        firebaseManager.fetchData()
        
        let logOutButton = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logOutButtonPressed))
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
        firebaseManager.fetchData(countImages: 1)
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
        
       
        
        cell.likeButtomTap = {
            self.dataModel.photos[indexPath.row].liked.toggle()
                if self.dataModel.photos[indexPath.row].liked == true {
                    cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                   
                    cell.heartView.alpha = 0.5
                    let seconds = 0.3
                    cell.likesCountLabel.text = self.dataManager.likeLabelConvert(counter: self.dataModel.photos[indexPath.row].likes)
                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                        cell.heartView.alpha = 0
                    }
                } else {
                    cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                }
            
            cell.likesCountLabel.text = self.dataManager.likeLabelConvert(counter: self.dataModel.photos[indexPath.row].likes)
                self.ref = Database.database().reference().child("photos/\(indexPath.row)")
                let  dict = ["liked":self.dataModel.photos[indexPath.row].liked, "likes":self.dataModel.photos[indexPath.row].likes] as [String : Any]
                self.ref.updateChildValues(dict)
        }
       
        cell.configure(dataModel: dataModel, indexPath: indexPath)
        
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
        DispatchQueue.main.async {
            self.dataModel.photos = image.photos + self.dataModel.photos
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
}


