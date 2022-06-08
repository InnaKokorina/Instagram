//
//  Posts.swift
//  Instagram
//
//  Created by Inna Kokorina on 11.05.2022.
//

import Foundation
import UIKit
import RealmSwift

struct Posts {
    var comment: [Comments]
    var descriptionImage: String = ""
    var id: String = ""
    var imageName: String = ""
    var image: UIImage?
    var likes: Int = 0
    var user: User
    var liked: Bool = false
}

struct Comments {
    var body: String = ""
    var email: String = ""
    var id: Int = 0
    var postId: String = ""
}

struct User {
    var userId: String = ""
    var userName: String = ""
    var userEmail: String = ""
    var userPhoto: UIImage?
  //  var userPhotoName: UIImage = UIImage(systemName: "person")!
}
