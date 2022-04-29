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
    
    func fetchData(countImages: Int = 11) {
        ref = Database.database().reference().child("photos")
        ref.observeSingleEvent(of: DataEventType.value) { snapshot in
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
                    let model = Photos(comment: self.comments, description: description as! String, id: id as! Int , image: image as! String, likes: likes as! Int, link: link as! String, user: user as! String, liked: liked as! Bool)
                    if self.dataModel.photos.count < countImages {
                        self.dataModel.photos.append(model)
                    }
                }
                self.delegate?.didUpdateImages(self, image: self.dataModel)
                self.comments = []
                self.dataModel.photos = []
                
            }
        }
    }
    
    
    func getImage(picName: String, completion: @escaping (UIImage) -> Void) {
        let storage = Storage.storage()
        let reference = storage.reference()
        let pathRef = reference.child("pictures")
        let fileRef = pathRef.child(picName + ".png")
        fileRef.getData(maxSize: 3048*3048, completion: { data, error in
            if let result = data {
                let image = UIImage(data: result)
                completion(image!)
            } else {
                print("error \(error)")
                let imageNil = UIImage(systemName: "xmark.circle")
                completion(imageNil!)
            }
        }
        )
    }
}


