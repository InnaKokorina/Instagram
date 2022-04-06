//
//  CommentsViewController.swift
//  Instagram
//
//  Created by Inna Kokorina on 06.04.2022.
//

import UIKit

class CommentsViewController: UIViewController {
    
    private let comments = [CommentsModel]()
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CommentsViewCell.self, forCellReuseIdentifier: "CommentsViewCell")
        return tableView
    }()
    
    
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        tableViewsSetup()
        
    }
    
    func tableViewsSetup() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = view.bounds
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        tableView.separatorColor = .clear
       
    }
}

extension CommentsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsViewCell", for: indexPath) as? CommentsViewCell else { return UITableViewCell() }
        cell.configure()
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
}
