//
//  ImagesModelAPI.swift
//  Instagram
//
//  Created by Inna Kokorina on 28.03.2022.
//

import Foundation
import UIKit

struct ImagesModelAPI: Codable {
    var hits: [Hits]
}

struct Hits: Codable {
    var id: Int
    var webformatURL: String
    var likes: Int
    var tags: String
    var user: String
}
