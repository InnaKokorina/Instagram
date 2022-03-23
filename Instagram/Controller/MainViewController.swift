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
  //  private var activityController: UIActivityViewController? = nil
    
    // init of model
    let images = (0...9).map{UIImage(named: String($0))!}
    var author: [String] = ["Inna Kokorina", "Ben Aflek", "Leo Di Caprio", "Janiffer Aniston", "Madonna", "Julia Roberts", "Alla Pugacheva", "Cameron Diaz", " The Beatles", "Queen"]
    var photoImageName = (0...9).map{String($0)}
    var likesCount = (0...9).map{_ in arc4random_uniform(100)}
    var descript:[String] = Array(repeating: ": Интересный факт о фруктах. в Японии фрукт преподносят в качестве подарка членам семьи, друзьям, коллегам и партнерам по бизнесу.", count: 10)
    
  
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
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.separatorColor = .clear
        
        for i in 0..<10 {
            
            self.dataModel.append(DataModel(author: author[i], photoImageName: photoImageName[i], likesCount: Int(likesCount[i]), description: descript[i]))
            
            self.tableView.reloadData()
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    
    
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        images.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as? MainTableViewCell else { return UITableViewCell() }
        
        cell.configure(with: images[indexPath.row], dataModel: dataModel, indexPath: indexPath)
      
        
        cell.likeButtomTap = {
            self.dataModel[indexPath.row].likesCount += 1
            cell.likesCountLabel.text = self.dataManager.likeLabelConvert(counter: self.dataModel[indexPath.row].likesCount)
            
            cell.heartImage.alpha = 0.5
            let seconds = 0.3
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                cell.heartImage.alpha = 0
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

