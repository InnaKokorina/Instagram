//
//  DataModel.swift
//  Instagram
//
//  Created by Inna Kokorina on 22.03.2022.
//

import Foundation
import UIKit
import RealmSwift

class PostsRealm: Object {
    dynamic var comment = List<CommentsRealm>()
    @objc dynamic var user: UserRealm?
    @objc dynamic var descriptionImage: String = ""
    @objc dynamic var id: Int  = 0
    @objc dynamic var imageName: String = ""
    @objc dynamic var image: Data?
    @objc dynamic var likes: Int = 0
    dynamic var likedByUsers = List<LikedByUsers>()
    @objc dynamic var link: String = ""
    @objc dynamic var liked: Bool = false
    @objc dynamic var location: String = ""

    convenience init(comment: List<CommentsRealm>, id: Int, imageName: String, likes: Int = 0, link: String, user: UserRealm, liked: Bool, descriptionImage: String, location: String, likedByUsers: List<LikedByUsers>) {
        self.init()
        self.comment = comment
        self.descriptionImage = descriptionImage
        self.id = id
        self.imageName = imageName
        self.likes = likes
        self.link = link
        self.user = user
        self.liked = liked
        self.location = location
        self.likedByUsers = likedByUsers
    }
}

class CommentsRealm: Object {
    @objc dynamic var body: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var id: Int = 0
    @objc dynamic var postId: Int  = 0
    dynamic var parentImage = LinkingObjects(fromType: PostsRealm.self, property: "comment")

  convenience init(body: String, email: String, id: Int, postId: Int) {
      self.init()
        self.body = body
        self.email = email
        self.id = id
        self.postId = postId
    }
}

class UserRealm: Object {
    @objc dynamic var userId: String = ""
    @objc dynamic var userName: String = ""
    @objc dynamic var userEmail: String = ""
    @objc dynamic var userPhoto: Data?

    convenience init(userId: String, userName: String, userEmail: String) {
      self.init()
        self.userId = userId
        self.userName = userName
        self.userEmail = userEmail
    }
}
class LikedByUsers: Object {
    @objc dynamic var userId: String = ""
    convenience init(userId: String) {
        self.init()
        self.userId = userId
    }
}
