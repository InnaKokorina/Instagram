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
    private var ref: DatabaseReference!
    private var dataModel: Results<Photos>?
    private var comments = List<CommentsModel>()
    let photosArray = List<Photos>()
  // MARK: - fetch data from FireBAse and save to Realm
    func fetchData() {
        // fetching from Firebase
        ref = Database.database().reference().child("photos")
        ref.observeSingleEvent(of: DataEventType.value) { snapshot in
            if snapshot.childrenCount > 0 {
                for data in snapshot.children.allObjects as! [DataSnapshot] {
                    let object =  data.value as? [String: AnyObject]
                    let user = object?["user"] as! String
                    let description = object?["description"] as! String
                    let id = object?["id"] as! Int
                    let image = object?["image"] as! String
                    let liked = object?["liked"] as! Bool
                    let likes = object?["likes"] as! Int
                    let link = object?["link"] as! String
                    for comment in data .children.allObjects as! [DataSnapshot] {
                        if let commentsArray  = comment.value as? [Any]  {
                            for i in commentsArray {
                                let oneCom = i as? [String: AnyObject]
                                let body = oneCom?["body"] as? String ?? ""
                                let email = oneCom?["email"] as? String ?? ""
                                let id = oneCom?["id"] as? Int ?? 0
                                let postId = oneCom?["postId"] as? Int ?? 0
                                self.comments.append(CommentsModel(body: body, email: email, id: id, postId: postId))
                            }
                        }
                    }
                    // save to Model
                    let post = Photos(comment: self.comments, id: id, imageName: image,  likes: likes, link: link, user: user, liked: liked, descriptionImage: description)
                    
                    self.comments = List<CommentsModel>()
                    // get Image
                    self.getImage(picName: image) { data in
                        post.image = data
                        self.photosArray.append(post)
                        
                        
                        // save to Realm
                        let realm = try! Realm()
                        do {
                            try realm.write({
                                realm.add(post)
                            })
                        } catch {
                            print("Error saving Data context \(error)")
                        }
                    }
                }
            }
        }
    }
    
    
 // MARK: - get Image from FireBase Storage
    func getImage(picName: String, completion: @escaping (Data) -> Void) {
        let storage = Storage.storage()
        var result = Data()
        let reference = storage.reference()
        let pathRef = reference.child("")
        let fileRef = pathRef.child(picName)
        fileRef.getData(maxSize: 1080*1080) { data, error in
            if let safeData = data {
                result = safeData
                completion(safeData)
                
            }
        }
    }
   // MARK: - uploadImage
    func uploadImage(_ image: UIImage, at reference: StorageReference, completion: @escaping (URL?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.1) else {
            return completion(nil)
        }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        reference.putData(imageData, metadata: metaData, completion: { (metadata, error) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                print("Upload failed :: ",error.localizedDescription)
                return completion(nil)
            }
            reference.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    return
                }
                completion(downloadURL)
            }
        })
    }
    
    func create(for image: UIImage,path: String, completion: @escaping (String?) -> ()) {
        let filePath = path
        let imageRef = Storage.storage().reference().child(filePath)
        uploadImage(image, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                print("Download url not found or error to upload")
                return completion(nil)
            }
            completion(downloadURL.absoluteString)
        }
    }
}


