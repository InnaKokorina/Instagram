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
    @objc dynamic var image: NSData?
    @objc dynamic var likes: Int = 0
    @objc dynamic var link: String = ""
    @objc dynamic var user: String = ""
    @objc dynamic var liked: Bool = false
    //        didSet {
    //            if liked {
    //                likes += 1
    //            } else {
    //                likes -= 1
    //            }
    //        }
    //    }
}


class CommentsModel: Object {
    @objc dynamic var body: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var id: Int = 0
    @objc dynamic var postId: Int = 0
    dynamic var parentImage = LinkingObjects(fromType: Photos.self, property: "comment")
    
}
