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
    //  private var activityController: UIActivityViewController? = nil
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MainTableViewCell.self, forCellReuseIdentifier: "MainTableViewCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.frame = view.bounds
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.separatorColor = .clear
        networkManager.delegate = self
        networkManager.fetchImages()
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataModel.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as? MainTableViewCell else { return UITableViewCell() }
        print("cell")
        cell.configure(dataModel: dataModel, indexPath: indexPath)
        
        cell.likeButtomTap = {
            self.dataModel[indexPath.row].isLiked.toggle()
            cell.likeButton.imageView?.alpha = 0.3
            cell.likeButton.setImage(UIImage(systemName: self.dataModel[indexPath.row].isLiked ? "heart.fill" : "heart"), for: .normal)
            cell.likesCountLabel.text = self.dataManager.likeLabelConvert(counter: self.dataModel[indexPath.row].likesCount)
            cell.heartView.alpha = 0.5
            let seconds = 0.3
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                cell.heartView.alpha = 0
            }
        }
        //            cell.shareButtonTap = {
        //                print("HI")
        //                self.activityController = UIActivityViewController(activityItems: [self.dataModel[indexPath.row].author], applicationActivities: nil)
        //                self.activityController?.present(MainViewController(), animated: true, completion: nil)
        //
        //            }
        return cell
    }
}


extension MainViewController : NetworkManagerDelegate {
    
    func didUpdateImages(_ networkManager:NetworkManager, image: [DataModel]) {
        DispatchQueue.main.async  {
            self.dataModel = image
            self.tableView.reloadData()
        }
    }
    
    func didFailWithError(error:Error) {
        print(error)
    }
    
}

