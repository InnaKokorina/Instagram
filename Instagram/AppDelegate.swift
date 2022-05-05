//
//  AppDelegate.swift
//  Instagram
//
//  Created by Inna Kokorina on 23.03.2022.
//

import UIKit
import Firebase
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    lazy var appViewController = UINavigationController(rootViewController: MainViewController())


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        FirebaseApp.configure()
               Auth.auth().addStateDidChangeListener {(auth,user) in
                   if user == nil {
                      lazy var appViewController = UINavigationController(rootViewController: AuthorizationViewController())
                       self.setupWindow(rootVC: appViewController)
                }
                   else {
                       lazy var appViewController = UINavigationController(rootViewController: MainViewController())
                       self.setupWindow(rootVC: appViewController)
                   }
               }
        print(Realm.Configuration.defaultConfiguration.fileURL ?? " no realm link")

                 do {
                 _ = try Realm()
                     
                 } catch {
                     print ("error instalation realm \(error)")
                 }
    
        return true
    }

func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    .init(rawValue: UIInterfaceOrientationMask.portrait.rawValue)
}

    func setupWindow(rootVC: UINavigationController) {
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = rootVC
    window?.makeKeyAndVisible()
}


}
