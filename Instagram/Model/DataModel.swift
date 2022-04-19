//
//  DataModel.swift
//  Instagram
//
//  Created by Inna Kokorina on 22.03.2022.
//

import Foundation
import UIKit

struct DataModel {
    var author: String = ""
    var photoImageUrl: String = ""
    var likesCount: Int = 0
    var description: String = ""
    var image: UIImage?
    var isLiked: Bool = false{
        didSet {
            if isLiked {
                likesCount += 1
            } else {
                likesCount -= 1
            }
        }
    }
}
