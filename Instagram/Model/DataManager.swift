//
//  DataManager.swift
//  Instagram
//
//  Created by Inna Kokorina on 21.03.2022.
//

import Foundation
import UIKit

struct DataManager {
    static var shared = DataManager()
    func likeLabelConvert(counter: Int) -> String {
        let formatString: String = NSLocalizedString("likes count", comment: "likes count string format to be found in Localized.stringsdict")
        let likesCount: String = String.localizedStringWithFormat(formatString, counter)
        let likesTextLabel = ("\(likesCount)")
        return likesTextLabel
    }
    func dateFormatter() -> String {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmm"
        let currentDateTimeString = formatter.string(from: currentDateTime)
        return currentDateTimeString
    }
    func tranferModeltoStruct(withPhoto photo: PostsRealm) -> Posts {
        var outputPosts = [Posts]()
        let id = photo.id
        let descriptionImage = photo.descriptionImage
        let imageName = photo.imageName
        let image = UIImage(data: photo.image!)
        let liked = photo.liked
        let likes = photo.likes
        let userID = photo.user?.userId ?? "0"
        let userName = photo.user?.userName ?? "User"
        let userEmail = photo.user?.userEmail ?? "User"
        let userPhoto = FirebaseManager.shared.setImage(data: photo.user?.userPhoto)
        let user = User(userId: userID, userName: userName, userEmail: userEmail, userPhoto: userPhoto)
        var comments = [Comments]()
        for comment in photo.comment {
            let id = comment.id
            let postId = comment.postId
            let email = comment.email
            let body = comment.body
            let oneComment = Comments(body: body, email: email, id: id, postId: postId)
            comments.append(oneComment)
        }
        let postElement = Posts(comment: comments, descriptionImage: descriptionImage, id: id, imageName: imageName, image: image, likes: likes, user: user, liked: liked)
        comments = []
        return postElement
    }
}
