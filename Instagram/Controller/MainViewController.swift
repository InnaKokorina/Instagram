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
import RealmSwift

class MainViewController: UIViewController {
    private var dataManager = DataManager()
    var dataModel: Results<Photos>?
    private var firebaseManager = FirebaseManager()
    private var activityController: UIActivityViewController? = nil
    private var ref: DatabaseReference!
    private let realm = try! Realm()
    private let spinner = SpinnerViewController()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MainTableViewCell.self, forCellReuseIdentifier: "MainTableViewCell")
        return tableView
    }()
    private let spinnerImage: UIImageView = {
        let image = UIImageView()
        return image
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavItems()
        view.addSubview(self.spinnerImage)
        spinnerImage.frame = self.view.bounds
        spinnerImage.isHidden = true

        if self.realm.isEmpty {
            self.spinnerImage.isHidden = false
            self.firebaseManager.fetchData()
            self.spinner.start(view: self.spinnerImage)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.spinner.stop()
                self.tableViewsSetup()
                self.spinnerImage.isHidden = true
                self.loadPosts()
            }
        }
        
        else {
            self.spinnerImage.isHidden = true
            self.tableViewsSetup()
            self.loadPosts()
        }
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
    // MARK: - navigationItems
    func setupNavItems() {
        let logOutButton = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logOutButtonPressed))
        logOutButton.tintColor = .black
        let addPhoto = UIBarButtonItem(image: UIImage(systemName: "plus.app"), style: .plain, target: self, action: #selector(addNewPost))
        addPhoto.tintColor = .black
        self.navigationItem.leftBarButtonItem  = logOutButton
        self.navigationItem.rightBarButtonItem = addPhoto
        navigationItem.title = Constants.App.title
    }
    
    @objc func logOutButtonPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch{
            print(error)
        }
    }
    @objc func addNewPost(_ sender: Any) {
        let vc = NewPhotoViewController()
        vc.dataModel = self.dataModel
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    // MARK: - RefreshImages
    @objc func callPullToRefresh() {
        do {
            try self.realm.write {
                realm.deleteAll()
            }
        } catch {
            print("error in deleting category \(error)")
        }
 
        DispatchQueue.main.async  {
            
          if self.realm.isEmpty {
            self.firebaseManager.fetchData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
//                self.loadPosts()
            }
            }
        }
    }
    
    
    func loadPosts () {
        dataModel = realm.objects(Photos.self).sorted(byKeyPath: "id", ascending: false)
     //   tableView.reloadData()
    }
}
// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataModel?.count ?? 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as? MainTableViewCell else { return UITableViewCell() }
        if let posts = self.dataModel {
            
            
            cell.likeButtomTap = {
                do {
                    try self.realm.write{
                        posts[indexPath.row].liked.toggle()
                        if posts[indexPath.row].liked == true {
                            cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                            posts[indexPath.row].likes += 1
                            cell.heartView.alpha = 0.5
                            let seconds = 0.3
                            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                cell.heartView.alpha = 0
                            }
                        } else {
                            cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                            posts[indexPath.row].likes -= 1
                        }
                        
                        cell.likesCountLabel.text = self.dataManager.likeLabelConvert(counter: posts[indexPath.row].likes)
                        self.ref = Database.database().reference().child("photos/\(posts[indexPath.row].id)")
                        let  dict = ["liked":posts[indexPath.row].liked, "likes":posts[indexPath.row].likes] as [String : Any]
                        self.ref.updateChildValues(dict)
                    }
                } catch {
                    print("Error saving Data context \(error)")
                }
                
            }
            cell.configure(dataModel: posts, indexPath: indexPath)
            
            cell.commentButtonPressed = { [weak self] in
                let vc = CommentsViewController()
                vc.selectedImage = posts[indexPath.row]
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        return cell
    }
    
}


