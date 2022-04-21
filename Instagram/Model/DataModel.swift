//
//  DataModel.swift
//  Instagram
//
//  Created by Inna Kokorina on 22.03.2022.
//

import Foundation
import UIKit

struct DataModel {
    var photos : [Photos]
}

struct Photos {
    var comment: [CommentsModel]
    var description: String = ""
    var id: Int = 0
    var image: String = ""
    var likes: Int = 0
    var link: String = ""
    var user: String = ""
    var liked: Bool = false {
        didSet {
            if liked {
                likes += 1
            } else {
                likes -= 1
            }
        }
    }
}


struct CommentsModel {
    var body: String = ""
    var email: String = ""
    var id: Int = 0
    var postId: Int = 0
    
}
