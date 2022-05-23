//
//  TabBarController.swift
//  Instagram
//
//  Created by Inna Kokorina on 20.05.2022.
//

import UIKit
import Firebase

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .black
        tabBar.backgroundColor = .white
        tabBar.isTranslucent = false

        Auth.auth().addStateDidChangeListener {(_, user) in
            if user == nil {
                self.presentAuthController()
            } else {
                self.setupViewControllers()
            }
        }
    }

    func setupViewControllers() {
        let homeNavController = UINavigationController(rootViewController: HomeViewController())
        let searchViewController = UINavigationController(rootViewController: SearchViewController())
        let newPhotoViewController = UINavigationController(rootViewController: NewPhotoViewController())
        let profileViewController = UINavigationController(rootViewController: ProfileViewController())
        setViewControllers([homeNavController, searchViewController, newPhotoViewController, profileViewController], animated: true)
        navigationController?.navigationBar.backgroundColor = .white
        guard let items = self.tabBar.items else { return }
        let images = ["house", "magnifyingglass", "plus.app", "person.crop.circle"]
        for index in 0..<items.count {
            items[index].image = UIImage(systemName: images[index])
        }
    }
    private func presentAuthController() {
        DispatchQueue.main.async {
            let authViewController = AuthorizationViewController()
            let navController = UINavigationController(rootViewController: authViewController)
            self.present(navController, animated: true, completion: nil)
        }
    }
}
