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
    var id: Int  = 0
    var imageName: String = ""
    var image: UIImage?
    var likes: Int = 0
    var user: User
    var liked: Bool = false
    var location: String = ""
}

struct Comments {
    var body: String = ""
    var email: String = ""
    var id: Int = 0
    var postId: Int  = 0
}

struct User {
    var userId: String = ""
    var userName: String = ""
    var userEmail: String = ""
    var userPhoto: UIImage?
}

struct Messages {
    var userId: String
    var partnerId: String
    var body: String
}
