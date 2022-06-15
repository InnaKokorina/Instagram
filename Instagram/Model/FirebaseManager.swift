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
import FirebaseFirestore
import RealmSwift

class FirebaseManager {
    static var shared = FirebaseManager()
    private var ref: DatabaseReference!
    private var comments = List<CommentsRealm>()
    private var currentUser = UserRealm()
    private let realm = try! Realm()
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
                    let descriptImage = object?["descriptionImage"] as? String ?? ""
                    let id = object?["id"] as? Int ?? 0
                    let image = object?["image"] as? String ?? ""
                    let liked = object?["liked"] as? Bool ?? false
                    let likes = object?["likes"] as? Int ?? 0
                    let link = object?["link"] as? String ?? ""
                    let location = object?["location"] as? String ?? ""
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
                    let post = PostsRealm(comment: self.comments, id: id, imageName: image, likes: likes, link: link, user: UserRealm(userId: userId, userName: userName, userEmail: userEmail), liked: liked, descriptionImage: descriptImage, location: location)

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
    // MARK: - setImageFromDataToUIImage
    func setImage(data: Data?) -> UIImage {
        if let safeData = data {
            return UIImage(data: safeData)!
        } else {
            return UIImage(systemName: "person")!
        }
    }
    // MARK: - saveCommentToRealmAndFB
    func saveComment(message: String, currentImage: PostsRealm ) {
            let email  = currentImage.user?.userName
            let id = currentImage.comment.count
            let postId = currentImage.id
            do {
                try realm.write {
                    let newcomment = CommentsRealm(body: message, email: email ?? "User", id: id, postId: postId)
                    currentImage.comment.append(newcomment)
                    self.ref =  Database.database().reference().child("photos/\(postId)/comments/\(id)")
                    let dictionary = ["email": newcomment.email, "body": newcomment.body, "id": newcomment.id, "postId": newcomment.postId] as [String: Any]
                    ref.setValue(dictionary)
                }
            } catch {
                print("Error saving Data context \(error)")
            }
    }
    // MARK: - saveNewPhotoToRealmAndFB
    func saveNewPhotoToRealmAndFB(dataModel: Results<PostsRealm>?, filePathStr: String, urlString: String, location: String, descriptionTextField: String) {
        let index: Int = dataModel?.count ?? 1
        let users = realm.objects(UserRealm.self)
         for eachUser in users where eachUser.userId == Auth.auth().currentUser!.uid {
            currentUser = eachUser
         }
        let post = PostsRealm(
            comment: List<CommentsRealm>(),
            id: index,
            imageName: filePathStr,
            likes: 0,
            link: urlString,
            user: currentUser,
            liked: false,
            descriptionImage: descriptionTextField,
            location: location)
        FirebaseManager.shared.getImage(picName: filePathStr) { data in
            post.image = data
       // }
            do {
                try self.realm.write {
                    self.realm.add(post)
                    self.ref = Database.database().reference().child("photos/\(index)")
                    // save to FB
                    let  dict = [
                        "userId": post.user?.userId ?? "",
                        "userName": post.user?.userName ?? "unknowedUser",
                        "userEmail": post.user?.userEmail ?? "",
                        "descriptionImage": post.descriptionImage,
                        "id": post.id,
                        "image": post.imageName,
                        "liked": post.liked,
                        "likes": post.likes,
                        "link": post.link,
                        "location": post.location,
                        "comments": Array(post.comment)
                    ] as [String: Any]
                    self.ref.setValue(dict)
                }
            } catch {
                print("Error saving Data context \(error)")
            }
        }
    }
}
