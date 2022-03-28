//
//  DataModel.swift
//  Instagram
//
//  Created by Inna Kokorina on 22.03.2022.
//

import Foundation
import UIKit

struct DataModel {
    var author: String
    var photoImageName: String
    var likesCount: Int
    var description: String
    var isLiked: Bool {
        didSet {
            if isLiked {
                likesCount += 1
            } else {
                likesCount -= 1
            }
        }
    }
}
