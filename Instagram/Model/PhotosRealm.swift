//
//  DataModel.swift
//  Instagram
//
//  Created by Inna Kokorina on 22.03.2022.
//

import Foundation
import UIKit
import RealmSwift

class Photos: Object {
    dynamic var comment = List<CommentsModel>()
    @objc dynamic var descriptionImage: String = ""
    @objc dynamic var id: Int = 0
    @objc dynamic var imageName: String = ""
    @objc dynamic var image: Data?
    @objc dynamic var likes: Int = 0
    @objc dynamic var link: String = ""
    @objc dynamic var user: String = ""
    @objc dynamic var liked: Bool = false

    convenience init(comment: List<CommentsModel>, id: Int, imageName: String, likes: Int = 0, link: String, user: String, liked: Bool, descriptionImage: String) {
        self.init()
        self.comment = comment
        self.descriptionImage = descriptionImage
        self.id = id
        self.imageName = imageName
        self.likes = likes
        self.link = link
        self.user = user
        self.liked = liked
    }
}

class CommentsModel: Object {
    @objc dynamic var body: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var id: Int = 0
    @objc dynamic var postId: Int = 0
    dynamic var parentImage = LinkingObjects(fromType: Photos.self, property: "comment")

  convenience init(body: String, email: String, id: Int, postId: Int) {
      self.init()
        self.body = body
        self.email = email
        self.id = id
        self.postId = postId
    }
}
