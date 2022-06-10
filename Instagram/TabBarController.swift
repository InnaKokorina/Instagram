//
//  TabBarController.swift
//  Instagram
//
//  Created by Inna Kokorina on 20.05.2022.
//

import UIKit
import Firebase
import RealmSwift

class TabBarController: UITabBarController {
   private var posts = [Posts]()
    private let realm = try! Realm()
    private var users: Results<UserRealm>?

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .black
        tabBar.backgroundColor = .white
        tabBar.isTranslucent = false
        self.tabBarItem.imageInsets = UIEdgeInsets(top: 10, left: 0, bottom: -4, right: 0)

        Auth.auth().addStateDidChangeListener {(_, user) in
            if user == nil {
                self.presentAuthController()
            } else {
                self.setupViewControllers()
            }
        }
    }

    func setupViewControllers() {
        let homeVC = HomeViewController()
        let profileVC = UserProfileViewController()
        let searchVC = SearchViewController()
        let chatVC = ChatViewController()
        let newPhotoVC = NewPhotoViewController()
        let homeNavController = UINavigationController(rootViewController: homeVC)
        let searchViewController = UINavigationController(rootViewController: searchVC)
        let newPhotoViewController = UINavigationController(rootViewController: newPhotoVC)
        let chatViewController = UINavigationController(rootViewController: chatVC)
        let profileNavController = UINavigationController(rootViewController: profileVC)
        setViewControllers([homeNavController, searchViewController, newPhotoViewController, chatViewController, profileNavController], animated: true)
        navigationController?.navigationBar.backgroundColor = .white
        guard let items = self.tabBar.items else { return }
        let images = ["house", "magnifyingglass", "plus.app", "message", "person.crop.circle"]
        for index in 0..<items.count {
            items[index].image = UIImage(systemName: images[index])
        }
    }
    func setNavigationControllers(rootVC: UIViewController) -> UINavigationController {
        let navigationVC = UINavigationController(rootViewController: rootVC)
        return navigationVC
    }
    private func presentAuthController() {
        DispatchQueue.main.async {
            let authViewController = AuthorizationViewController()
            let navController = UINavigationController(rootViewController: authViewController)
            self.present(navController, animated: true, completion: nil)
        }
    }
}
