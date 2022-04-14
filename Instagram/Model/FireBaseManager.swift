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
    
    
    func getData() {
        var ref: DatabaseReference!
        var dataModel = DataModel(photos: [Photos]())
        ref = Database.database().reference().child("photos")
        ref.observe(DataEventType.value) { snapshot in
            if snapshot.childrenCount > 0 {
                
                for i in snapshot.children.allObjects as! [DataSnapshot] {
                    let object =  i.value as? [String: AnyObject]
                    let user = object?["user"]
                    let description = object?["description"]
                    let id = object?["id"]
                    let image = object?["image"]
                    let liked = object?["liked"]
                    let likes = object?["likes"]
                    let link = object?["link"]
                    //   let comments = object?["comments"]
                    let model = Photos(description: description as! String, id: id as! Int, image: image as! String, likes: likes as! Int, link: link as! String, user: user as! String)
                    dataModel.photos.append(model)
                    
                }
               
                self.delegate?.didUpdateImages(self, image: dataModel)
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

