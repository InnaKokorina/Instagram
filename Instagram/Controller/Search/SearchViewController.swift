//
//  SearchViewController.swift
//  Instagram
//
//  Created by Inna Kokorina on 20.05.2022.
//

import UIKit
import FirebaseAuth
import RealmSwift

class SearchViewController: UIViewController {
    private var didSetupConstraints = false
    private var users: Results<UserRealm>?
    private let realm = try! Realm()
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Введите пользователя..."
        return searchBar
    }()
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchViewCell.self, forCellReuseIdentifier: SearchViewCell.identifier)
        tableView.separatorStyle = .none
        return tableView
    }()
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(searchBar)
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        view.setNeedsUpdateConstraints()
        loadUsers()
        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavItems()
    }
    // MARK: - loadArray
    func loadUsers() {
            users = realm.objects(UserRealm.self).sorted(byKeyPath: "userName", ascending: true)
    }
    // MARK: - navigationItems
    func setupNavItems() {
        let logOutButton = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logOutButtonPressed))
        logOutButton.tintColor = .black
        navigationItem.rightBarButtonItem  = logOutButton
        navigationItem.title = Constants.App.titleSearch
    }

    @objc func logOutButtonPressed(_ sender: Any) {
        do {
            navigationController?.popViewController(animated: true)
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
    }
}
// MARK: - UITableViewDataSource, UITableViewDelegate
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let uniqueUsers = DataManager.shared.uniqueArray(array: users!, authUserId: Auth.auth().currentUser?.uid)
        return uniqueUsers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchViewCell.identifier, for: indexPath) as? SearchViewCell else { return UITableViewCell() }
       if let usersNotEmpty = users {
        let uniqueUsers = DataManager.shared.uniqueArray(array: usersNotEmpty, authUserId: Auth.auth().currentUser?.uid)
           cell.userLabel.text = uniqueUsers[indexPath.row].userName
           if let photoData =  uniqueUsers[indexPath.row].userPhoto {
           cell.personImage.image = UIImage(data: photoData)
           }
           cell.selectionStyle = .none
      }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        let userProfileController = UserProfileViewController()
        if let usersNotEmpty = users {
        userProfileController.user = DataManager.shared.uniqueArray(array: usersNotEmpty, authUserId: Auth.auth().currentUser?.uid)[indexPath.row]
        navigationController?.pushViewController(userProfileController, animated: true)
        }
    }
}
// MARK: - updateViewConstraints
extension SearchViewController {
    override func updateViewConstraints() {
        if !didSetupConstraints {
            searchBar.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide)
                make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
                make.height.equalTo(70)
            }
            tableView.snp.makeConstraints { make in
                make.top.equalTo(searchBar.snp.bottom)
                make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
                make.bottom.equalTo(view)
            }
            didSetupConstraints = true
        }
        super.updateViewConstraints()
    }
}
// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        users = users?.filter("userName CONTAINS[cd] %@", searchBar.text!)
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadUsers()
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
