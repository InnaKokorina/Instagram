
//
//  DataManager.swift
//  Instagram
//
//  Created by Inna Kokorina on 21.03.2022.
//

import Foundation
import UIKit

struct DataManager {
    var images = (0...9).map{UIImage(named: String($0))!}
    var author: [String] = ["Inna Kokorina", "Ben Aflek", "Leo Di Caprio", "Jeniffer Aniston", "Madonna", "Julia Roberts", "Alla Pugacheva", "Cameron Diaz", " The Beatles", "Queen"]
    var photoImageName = (0...9).map{String($0)}
    var likesCount = (0...9).map{_ in arc4random_uniform(100)}
    var descript:[String] = Array(repeating: ": Интересный факт о фруктах. в Японии фрукт преподносят в качестве подарка членам семьи, друзьям, коллегам и партнерам по бизнесу.", count: 10)
    
    func likeLabelConvert(counter: Int) -> String {
        let formatString: String = NSLocalizedString("likes count", comment: "likes count string format to be found in Localized.stringsdict")
        let likesCount : String = String.localizedStringWithFormat(formatString, counter)
        let likesTextLabel = ("\(counter) \(likesCount)")
        return likesTextLabel
    }
}
