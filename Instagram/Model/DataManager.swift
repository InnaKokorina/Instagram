
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
        let formatString: String = NSLocalizedString("likes count", comment: "likes count string format to be found in Localized.stringsdict")
        let likesCount : String = String.localizedStringWithFormat(formatString, counter)
        let likesTextLabel = ("\(likesCount)")
        return likesTextLabel
    }
    func dateFormatter() -> String  {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHH:mm"
        let currentDateTimeString = formatter.string(from: currentDateTime)
        return currentDateTimeString
    }
}
