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

//protocol FirebaseManagerDelegate {
//   func didUpdateImages(_ firebaseManager: FirebaseManager, image: Photos)
//  func didUpdateComments(_ firebaseManager: FirebaseManager, comment: [CommentsModel])
//}

class FirebaseManager {
    
    //  var delegate: FirebaseManagerDelegate?
    private var ref: DatabaseReference!
    private var dataModel: Results<Photos>?
    private var comments = List<CommentsModel>()
    private var realmManager = RealmManager()
    let photosArray = List<Photos>()
    
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
                      //  print(" realm.add(self.photosArray) ---\(photosArray)")
                    })
                } catch {
                    print("Error saving Data context \(error)")
                }
            }
            //  self.delegate?.didUpdateImages(self, image: self.dataModel)
        }
        }
    }
    }
    
    
    
    
    func getImage(picName: String, completion: @escaping (Data) -> Void) {
        let storage = Storage.storage()
        var result = Data()
        let reference = storage.reference()
        let pathRef = reference.child("")
        let fileRef = pathRef.child(picName)
        fileRef.getData(maxSize: 1080*1080) { data, error in
            if let safeData = data {
                    result = safeData
                    print("result in closure \(result)")
                    completion(safeData)
               
            }
        }
    }
    
    func saveImage() {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        // File located on disk
        let localFile = URL(string: "path/to/image")!
        
        // Create a reference to the file you want to upload
        let picRef = storageRef.child("pictures")
        
        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = picRef.putFile(from: localFile, metadata: nil) { metadata, error in
            guard let metadata = metadata else { return }
            picRef.downloadURL { (url, error) in
                guard let downloadURL = url else { return }
            }
        }
    }
    
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


