//
//  PostViewModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 11/08/23.
//

import Foundation
import Photos
import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class PostViewModel {
    static let shared = PostViewModel()
    var imagesArray: [UIImage] = []
    private init(){}
    
    func fetchAllPhotos(completion: @escaping ([UIImage]) -> Void) {
        var images: [UIImage] = []
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        let imageManager = PHImageManager.default()
        
        fetchResult.enumerateObjects { asset, _, _ in
            let targetSize = CGSize(width: 700, height: 700) // Adjust the target size as needed
            
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            
            imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: requestOptions) { image, _ in
                if let image = image {
                    images.append(image)
                }
            }
        }
        completion(images)
    }
    
    
    func uploadImageToFirebaseStorage(image: UIImage, caption: String, location: String, completionHandler: @escaping (Bool) -> Void) {
        FetchUserInfo.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case .success(let data):
                if let data = data {
                    let imageName = "\(Int(Date().timeIntervalSince1970)).jpg"
                    let storageRef = Storage.storage().reference().child("images/\(imageName)")
                    if let imageData = image.jpegData(compressionQuality: 0.5) {
                        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                            if let error = error {
                                print("Error uploading image: \(error.localizedDescription)")
                                completionHandler(false)
                            } else {
                                // Image uploaded successfully, now you can get the download URL
                                storageRef.downloadURL { (url, error) in
                                    if let downloadURL = url {
                                        // The downloadURL contains the URL to the uploaded image
                                        print("Image uploaded to: \(downloadURL)")
                                        
                                        // Get the UID of the currently authenticated user
                                        guard let uid = Auth.auth().currentUser?.uid else {
                                            print("User is not authenticated.")
                                            return
                                        }
                                        
                                        let db = Firestore.firestore()
                                        if let name = data.name, let profileImageUrl = data.imageUrl {
                                            // Include UID in the document data
                                            var imageDocData: [String: Any] = [
                                                "postImageURL": downloadURL.absoluteString,
                                                "caption": caption,
                                                "location": location,
                                                "name": name,
                                                "profileImageUrl": profileImageUrl,
                                                "uid": uid
                                            ]
                                            
                                            // Declare documentRef outside of the closure
                                            var documentRef: DocumentReference!
                                            
                                            // Add the document to Firestore and get the generated document ID
                                            documentRef = db.collection("post").addDocument(data: imageDocData) { (error) in
                                                if let error = error {
                                                    print("Error adding document: \(error)")
                                                    completionHandler(false)
                                                } else {
                                                    print("Document added successfully")
                                                    
                                                    // Retrieve the generated document ID
                                                    let documentID = documentRef.documentID
                                                    
                                                    // Update the document with the postDocumentID
                                                    db.collection("post").document(documentID).setData(["postDocumentID": documentID], merge: true) { error in
                                                        if let error = error {
                                                            print("Error updating document: \(error)")
                                                        }
                                                    }
                                                    
                                                    completionHandler(true)
                                                }
                                            }
                                        }
                                    } else {
                                        print("Error getting image download URL: \(error?.localizedDescription ?? "")")
                                        completionHandler(false)
                                    }
                                }
                            }
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    
    
    func fetchPostDataOfPerticularUser(forUID uid: String, completion: @escaping (Result<[PostModel], Error>) -> Void) {
        let db = Firestore.firestore()
        // Query the "images" collection with a filter for the provided UID
        db.collection("post")
            .whereField("uid", isEqualTo: uid)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching images: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    var images: [PostModel] = []
                    for document in querySnapshot!.documents {
                        if let postImageURL = document["postImageURL"] as? String,
                           let caption = document["caption"] as? String,
                           let location = document["location"] as? String,
                           let name = document["name"] as? String,
                           let postDocumentID = document["postDocumentID"] as? String,
                           let profileImageUrl = document["profileImageUrl"] as? String {
                            let image = PostModel(
                                postImageURL: postImageURL,
                                caption: caption,
                                location: location,
                                name: name,
                                uid: uid,
                                profileImageUrl: profileImageUrl, postDocumentID: postDocumentID
                            )
                            images.append(image)
                        }
                    }
                    completion(.success(images))
                }
            }
    }
    
    
    
    func fetchAllPosts(completion: @escaping (Result<[PostModel], Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("post")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching images: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    var images: [PostModel] = []
                    for document in querySnapshot!.documents {
                        if let postImageURL = document["postImageURL"] as? String,
                           let caption = document["caption"] as? String,
                           let location = document["location"] as? String,
                           let name = document["name"] as? String,
                           let uid = document["uid"] as? String ,
                           let postDocumentID = document["postDocumentID"] as? String ,
                           let profileImageUrl = document["profileImageUrl"] as? String {
                            let image = PostModel(postImageURL: postImageURL, caption: caption, location: location, name: name, uid: uid, profileImageUrl: profileImageUrl, postDocumentID: postDocumentID)
                            images.append(image)
                        }
                    }
                    completion(.success(images))
                }
            }
    }
    
    
    func likePost(postDocumentID: String, userUID: String) {
        let db = Firestore.firestore()
        let postDocumentRef = db.collection("post").document(postDocumentID)
        
        // Update the 'likedBy' array to add the user's UID and increment the 'likesCount'
        let batch = db.batch()
        batch.updateData(["likedBy": FieldValue.arrayUnion([userUID])], forDocument: postDocumentRef)
        batch.updateData(["likesCount": FieldValue.increment(Int64(1))], forDocument: postDocumentRef)
        
        batch.commit { error in
            if let error = error {
                print("Error liking post: \(error.localizedDescription)")
            } else {
                print("Post liked by user with UID: \(userUID)")
            }
        }
    }

    func unlikePost(postDocumentID: String, userUID: String) {
        let db = Firestore.firestore()
        let postDocumentRef = db.collection("post").document(postDocumentID)
        
        // Update the 'likedBy' array to remove the user's UID and decrement the 'likesCount'
        let batch = db.batch()
        batch.updateData(["likedBy": FieldValue.arrayRemove([userUID])], forDocument: postDocumentRef)
        batch.updateData(["likesCount": FieldValue.increment(Int64(-1))], forDocument: postDocumentRef)
        
        batch.commit { error in
            if let error = error {
                print("Error unliking post: \(error.localizedDescription)")
            } else {
                print("Post unliked by user with UID: \(userUID)")
            }
        }
    }

    
    
    
    // Function to increment the likes count for a post
    func incrementLikesCountForPost(postDocumentRef: DocumentReference) {
        postDocumentRef.updateData(["likesCount": FieldValue.increment(Int64(1))]) { error in
            if let error = error {
                print("Error incrementing likes count: \(error.localizedDescription)")
            } else {
                print("Likes count incremented for post")
            }
        }
    }
    
    // Function to decrement the likes count for a post
    func decrementLikesCountForPost(postDocumentRef: DocumentReference) {
        postDocumentRef.updateData(["likesCount": FieldValue.increment(Int64(-1))]) { error in
            if let error = error {
                print("Error decrementing likes count: \(error.localizedDescription)")
            } else {
                print("Likes count decremented for post")
            }
        }
    }
    
    
    
    
}
