//
//  DataManager.swift
//  Instagram
//
//  Created by Inna Kokorina on 21.03.2022.
//

import Foundation
import UIKit
import RealmSwift

struct DataManager {
    static var shared = DataManager()
    // MARK: - likeLabelConvert
    func likeLabelConvert(counter: Int) -> String {
        let formatString: String = NSLocalizedString("likes count", comment: "likes count string format to be found in Localized.stringsdict")
        let likesCount: String = String.localizedStringWithFormat(formatString, counter)
        let likesTextLabel = ("\(likesCount)")
        return likesTextLabel
    }
    // MARK: - dateFormatter
    func dateFormatter() -> String {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmm"
        let currentDateTimeString = formatter.string(from: currentDateTime)
        return currentDateTimeString
    }
    // MARK: - uniqueArray
    func uniqueArray(array: Results<UserRealm>, authUserId: String?) -> [UserRealm] {
        var unique = [UserRealm]()
        var notContains = false
        unique = [UserRealm(userId: " ", userName: " ", userEmail: " ")]
        for element in array {
            for one in unique {
                if element.userId != one.userId && element.userId != authUserId {
                    notContains = true
                }
                if element.userId == one.userId {
                    notContains  = false
                    continue
                }
            }
            if notContains == true {
                unique.append(element)
            }
        }
        unique.removeFirst()
        return unique
    }
    // MARK: - likedByUser
    func likedByUser(currentUserId: String, usersArray: List<LikedByUsers> ) -> Bool {
        var liked = false
        for element in usersArray {
            if element.userId != currentUserId {
                liked = false
            }
            if element.userId == currentUserId {
                liked = true
                break
            }
        }
        return liked
    }
    // MARK: - attributedText
    func attributedText(normStr: String, boldStr: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: normStr)
        let attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)]
        let boldString = NSMutableAttributedString(string: boldStr, attributes: attrs)
        boldString.append(attributedString)
        return boldString
    }
}
