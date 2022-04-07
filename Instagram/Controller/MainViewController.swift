//
//  MainViewController.swift
//  Instagram
//
//  Created by Inna Kokorina on 20.03.2022.
//

import UIKit

class MainViewController: UIViewController {
    private var dataManager = DataManager()
    private var dataModel = [DataModel]()
    private var networkManager = NetworkManager()
    private var activityController: UIActivityViewController? = nil
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MainTableViewCell.self, forCellReuseIdentifier: "MainTableViewCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableViewsSetup()
        networkManager.delegate = self
        networkManager.fetchImages(imagesCount: 10)
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
        networkManager.fetchImages(imagesCount: 1)
    }
}
// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataModel.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as? MainTableViewCell else { return UITableViewCell() }
        cell.configure(dataModel: dataModel, indexPath: indexPath)
        
        cell.likeButtomTap = {
            self.dataModel[indexPath.row].isLiked.toggle()
            if self.dataModel[indexPath.row].isLiked {
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
            
            cell.likesCountLabel.text = self.dataManager.likeLabelConvert(counter: self.dataModel[indexPath.row].likesCount)
        }
        
        cell.commentButtonPressed = {
            let vc = CommentsViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            
            DispatchQueue.main.async {
                vc.selectedImage = self.dataModel[indexPath.row]
            }
            
        }
        return cell
    }
    
    
}

// MARK: - NetworkManagerDelegate

extension MainViewController : NetworkManagerDelegate {
    
    func didUpdateImages(_ networkManager:NetworkManager, image: [DataModel]) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.dataModel = image + self.dataModel
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
        }
    }
    
    func didFailWithError() {
        print("ошибка сети")
    }
}

