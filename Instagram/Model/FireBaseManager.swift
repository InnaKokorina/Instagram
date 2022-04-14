//
//  FireBaseManager.swift
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
    func didUpdateImages(_ firebaseManager: FireBaseManager, image: DataModel)
}

class FireBaseManager {
    
    static let shared = FireBaseManager()
    var delegate: FirebaseManagerDelegate?
    //
    //    private func configureFB() -> Firestore {
    //        var db: Firestore!
    //        let setting = FirestoreSettings()
    //        Firestore.firestore().settings = setting
    //        db = Firestore.firestore()
    //        return db
    //    }
    //
    //    func getPost(collection:String, docName:String, completion: @escaping (DataModel?) -> Void) {
    //        let db = configureFB()
    //        db.collection(collection: collection).document(docName).getDocument(completion: { (document, error) in
    //            guard error == nil else { completion(nil); return)
    //                let doc = DataModel(<#code#>
    //        }
    //})
    //}

    
    func getData() {
        var ref: DatabaseReference!
        var dataModel = DataModel(photos: [Photos]())
        ref = Database.database().reference().child("photos")
        ref.observe(DataEventType.value) { snapshot in
            if snapshot.childrenCount > 0 {
                
                for data in snapshot.children.allObjects as! [DataSnapshot] {
                    let object =  data.value as? [String: AnyObject]
                    print("objectComment ----\(object)")
                    let user = object?["user"]
                    let description = object?["description"]
                    let id = object?["id"]
                    let image = object?["image"]
                    let liked = object?["liked"]
                    let likes = object?["likes"]
                    let link = object?["link"]
                    
//                    let comments: NSArray = object?["comments"]

                    for comment in data .children.allObjects as! [DataSnapshot] {
                            let objectComment = comment.value as? [String: AnyObject]
                        
                        
                        print("comment.value ----\(comment.value)")
                            let body = objectComment?["body"] as? String ?? ""
                            let email = objectComment?["email"] as? String ?? ""
                            let id = objectComment?["id"] as? Int ?? 0
                            let postId = objectComment?["postId"] as? Int ?? 0

                            let commentsModel = CommentsModel(body: body, email: email, id: id, postId: postId)
                            
                            let model = Photos(comment: [commentsModel], description: description as! String, id: id as! Int, image: image as! String, likes: likes as! Int, link: link as! String, user: user as! String)
                            dataModel.photos.append(model)
                            print("comment ----\(dataModel.photos[0].comment[2].body)")
                        }
                        
                        self.delegate?.didUpdateImages(self, image: dataModel)
                    }
             //   }
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

