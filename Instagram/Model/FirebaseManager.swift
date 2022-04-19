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

protocol FirebaseManagerDelegate {
    func didUpdateImages(_ firebaseManager: FirebaseManager, image: DataModel)
    func didUpdateComments(_ firebaseManager: FirebaseManager, comment: [CommentsModel])
}

class FirebaseManager {
    
    static let shared = FirebaseManager()
    var delegate: FirebaseManagerDelegate?
    private var ref: DatabaseReference!
    private var dataModel = DataModel(photos: [Photos]())
    private var comments = [CommentsModel]()
    
    func fetchData() {
        ref = Database.database().reference().child("photos")
        ref.observe(DataEventType.value) { snapshot in
            if snapshot.childrenCount > 0 {
                
                for data in snapshot.children.allObjects as! [DataSnapshot] {
                    let object =  data.value as? [String: AnyObject]
                    let user = object?["user"]
                    let description = object?["description"]
                    let id = object?["id"]
                    let image = object?["image"]
                    let liked = object?["liked"]
                    let likes = object?["likes"]
                    let link = object?["link"]
                    var commentsModel  = CommentsModel()
                    for comment in data .children.allObjects as! [DataSnapshot] {
                      //  let objectComment = comment.value as? [String: AnyObject]
                        if let commentsArray  = comment.value as? [Any]  {
                            for i in commentsArray {
                                let oneCom = i as? [String: AnyObject]
                                let body = oneCom?["body"] as? String ?? ""
                                let email = oneCom?["email"] as? String ?? ""
                                let id = oneCom?["id"] as? Int ?? 0
                                let postId = oneCom?["postId"] as? Int ?? 0
                                commentsModel = CommentsModel(body: body, email: email, id: id, postId: postId)
                                self.comments.append(commentsModel)
                                self.delegate?.didUpdateComments(self, comment: self.comments)
                            }
                        }
                    }
                    let model = Photos(comment: [commentsModel], description: description as! String, id: id as! Int , image: image as! String, likes: likes as! Int, link: link as! String, user: user as! String, liked: liked as! Bool)
                    self.dataModel.photos.append(model)
                    self.delegate?.didUpdateImages(self, image: self.dataModel)
                    
                }
            }
        }
    }
    
    
    func getImage(picName: String, completion: @escaping (UIImage) -> Void) {
        let storage = Storage.storage()
        let reference = storage.reference()
        let pathRef = reference.child("pictures")
        let fileRef = pathRef.child(picName + ".png")
        fileRef.getData(maxSize: 3048*3048, completion: { data, error in
            guard error == nil else {
                print("error \(error)")
                return
            }
            let image = UIImage(data: data!)!
            completion(image)
        }
        )
    }
    
//    func saveData(dataModel: DataModel) {
//        ref = Database.database().reference().child("photos")
//        var photos : Dictionary<String, Any> = [:]
//        var array : [Dictionary<String, Any>] = [[:]]
//        var commentsArray: [Dictionary<String, Any>] = [[:]]
//        for i in dataModel.photos {
//            print("dataModel.photos.count = \(dataModel.photos.count)")
//            for comment in i.comment {
//                print("comments.count = \(i.comment.count)")
//                let commentData : Dictionary<String, Any> = ["id": comment.id, "email": comment.email, "postId": comment.postId, "body":comment.body]
//                commentsArray.append(commentData)
//            }
//            let data : Dictionary<String, Any> = ["user" : i.user, "description" : i.description, "id" : i.id, "image": i.image, "liked": i.liked, "likes": i.likes , "link": i.link, "comments": commentsArray ]
//            array.append(data)
//        commentsArray = [[:]]
//    }
//        photos = ["photos": array]
//        self.ref.updateChildValues(photos)
//      //  print("liked????\(photos["photos"])")
//    }
}


