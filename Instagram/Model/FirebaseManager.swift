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
}

class FirebaseManager {
    
    static let shared = FirebaseManager()
    var delegate: FirebaseManagerDelegate?
    
    func fetchData() {
        var ref: DatabaseReference!
        var dataModel = DataModel(photos: [Photos]())
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
                        let objectComment = comment.value as? [String: AnyObject]
                        if let commentsArray  = comment.value as? [Any]  {
                            for i in commentsArray {
                                let oneCom = i as? [String: AnyObject]
                                let body = oneCom?["body"] as? String ?? ""
                                let email = oneCom?["email"] as? String ?? ""
                                let id = oneCom?["id"] as? Int ?? 0
                                let postId = oneCom?["postId"] as? Int ?? 0
                                
                                commentsModel = CommentsModel(body: body, email: email, id: id, postId: postId)
                            }
                        }
                    }
                    let model = Photos(comment: [commentsModel], description: description as! String, id: id as! Int , image: image as! String, likes: likes as! Int, link: link as! String, user: user as! String)
                    dataModel.photos.append(model)
                    print("comment ----\(dataModel.photos[0].comment[0].body)")
                    
                    self.delegate?.didUpdateImages(self, image: dataModel)
                    
                }
            }
        }
    }
    
    
    func getImage(picName: String, completion: @escaping (UIImage) -> Void) {
        let storage = Storage.storage()
        let reference = storage.reference()
        let pathRef = reference.child("pictures")
        print("path Ref -----\(pathRef)")
        let fileRef = pathRef.child(picName + ".png")
        print("fileRef -----\(fileRef)")
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
}


