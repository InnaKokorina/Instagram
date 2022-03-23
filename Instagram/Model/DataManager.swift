
//
//  DataManager.swift
//  Instagram
//
//  Created by Inna Kokorina on 21.03.2022.
//

import Foundation
import UIKit

struct DataManager {
    
 
    func likeLabelConvert(counter: Int) -> String {
        var textLabel = ""
        var reCounter = counter % 100
        if counter > 100 {
            reCounter = counter % 100
        }
        if reCounter >= 10 && reCounter <= 20 {
            textLabel = "\(counter) лайков"
        } else {
            reCounter = reCounter % 10
            switch reCounter {
            case 1 : textLabel = "\(counter) лайк"
            case 2,3,4 : textLabel = "\(counter) лайка"
            default: textLabel = "\(counter) лайков"
   
            }
        }

        return textLabel
    }
    
    func makeList(_ n: Int) -> [Int] {
        return (0..<n).map { _ in .random(in: 1...20) }
    }
}
