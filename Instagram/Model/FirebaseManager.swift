//
//  FirebaseManager.swift
//  Instagram
//
//  Created by Inna Kokorina on 14.04.2022.
//

import Foundation
import FirebaseAuth
import Firebase
import FirebaseDatabase
import FirebaseStorage
import RealmSwift

class FirebaseManager {
    static var shared = FirebaseManager()
    private var ref: DatabaseReference!
    private var comments = List<CommentsRealm>()
    let posts = List<PostsRealm>()
  // MARK: - fetch data from FireBAse and save to Realm
    func fetchData(completion: @escaping(PostsRealm) -> Void) {
        // fetching from Firebase
        ref = Database.database().reference().child("photos")
        ref.observeSingleEvent(of: DataEventType.value) { snapshot in
            if snapshot.childrenCount > 0 {
                for data in snapshot.children.allObjects as! [DataSnapshot] {
                    let object =  data.value as? [String: AnyObject]
                    let userId = object?["userId"] as? String ?? ""
                    let userName = object?["userName"] as? String ?? ""
                    let userEmail = object?["userEmail"] as? String ?? ""
                    let descriptionImage = object?["descriptionImage"] as? String ?? ""
                    let id = object?["id"] as? Int ?? 0
                    let image = object?["image"] as? String ?? ""
                    let liked = object?["liked"] as? Bool ?? false
                    let likes = object?["likes"] as? Int ?? 0
                    let link = object?["link"] as? String ?? ""
                    for comment in data .children.allObjects as! [DataSnapshot] {
                        if let commentsArray  = comment.value as? [Any] {
                            for one in commentsArray {
                                let oneCom = one as? [String: AnyObject]
                                let body = oneCom?["body"] as? String ?? ""
                                let email = oneCom?["userName"] as? String ?? ""
                                let id = oneCom?["id"] as? Int ?? 0
                                let postId = oneCom?["postId"] as? Int ?? 0
                                self.comments.append(CommentsRealm(body: body, email: email, id: id, postId: postId))
                            }
                        }
                    }
                    // save to Model
                    let post = PostsRealm(comment: self.comments, id: id, imageName: image, likes: likes, link: link, user: UserRealm(userId: userId, userName: userName, userEmail: userEmail), liked: liked, descriptionImage: descriptionImage)

                    self.comments = List<CommentsRealm>()

                    self.getImage(picName: image) { postData in
                        post.image = postData
                        self.getImage(picName: "\(post.user!.userId).jpg") { userData in
                            post.user?.userPhoto = userData
                            self.posts.append(post)
                            completion(post)
                        }
                    }
                }
            }
        }
    }

 // MARK: - get Image from FireBase Storage
    func getImage(picName: String, completion: @escaping (Data?) -> Void) {
        let pathRef = Storage.storage().reference()
        let fileRef = pathRef.child(picName)

   fileRef.getData(maxSize: 1080*1080) { data, _ in
            if let safeData = data {
                completion(safeData)
            } else {
                completion(nil)
            }
        }
    }
   // MARK: - uploadImage to Storage
    func uploadImage(for image: UIImage, path: String, completion: @escaping (String?) -> Void) {
        let filePath = path
        let imageRef = Storage.storage().reference().child(filePath)
        guard let imageData = image.jpegData(compressionQuality: 0.1) else {
            return completion(nil)
        }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        imageRef.putData(imageData, metadata: metaData) { (_, error) in
            if let error = error {
                print("Upload failed", error.localizedDescription)
                return completion(nil)
            }
            imageRef.downloadURL { (url, _) in
                guard let downloadURL = url else {
                    return
                }
                completion(downloadURL.absoluteString)
            }
        }
    }
    func setImage(data: Data?) -> UIImage  {
        if let safeData = data {
            return UIImage(data: safeData)!
        } else {
            return UIImage(systemName: "person")!
        }
    }
}
