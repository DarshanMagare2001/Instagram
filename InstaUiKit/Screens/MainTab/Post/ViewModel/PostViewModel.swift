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
import Firebase

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
                                            completionHandler(false)
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
                                                "uid": uid,
                                                "timestamp": FieldValue.serverTimestamp() // Add timestamp
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
                completionHandler(false)
            }
        }
    }
    
    func fetchPostDataOfPerticularUser(forUID uid: String, completion: @escaping (Result<[PostModel], Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("post")
            .whereField("uid", isEqualTo: uid)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    var posts: [PostModel] = []
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        print("Document ID: \(document.documentID)")
                        print("Data: \(data)")
                        let postImageURL = data["postImageURL"] as? String ?? ""
                        let caption = data["caption"] as? String ?? ""
                        let location = data["location"] as? String ?? ""
                        let name = data["name"] as? String ?? ""
                        let profileImageUrl = data["profileImageUrl"] as? String ?? ""
                        let postDocumentID = data["postDocumentID"] as? String ?? ""
                        let likedBy = data["likedBy"] as? [String] ?? []
                        let likesCount = data["likesCount"] as? Int ?? 0
                        let comments = data["comments"] as? [[String : Any]] ?? []
                        // Correctly initialize timestamp with FieldValue.serverTimestamp()
                        let timestamp = data["timestamp"] as? FieldValue ?? FieldValue.serverTimestamp()
                        let post = PostModel(
                            postImageURL: postImageURL,
                            caption: caption,
                            location: location,
                            name: name,
                            uid: uid,
                            profileImageUrl: profileImageUrl,
                            postDocumentID: postDocumentID,
                            likedBy: likedBy,
                            likesCount: likesCount,
                            comments: comments,
                            timestamp: timestamp
                        )
                        posts.append(post)
                    }
                    print("Fetched \(posts.count) posts.")
                    completion(.success(posts))
                }
            }
    }
    
    
    
    
    func fetchAllPosts(completion: @escaping (Result<[PostModel], Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("post")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    var posts: [PostModel] = []
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let postImageURL = data["postImageURL"] as? String ?? ""
                        let caption = data["caption"] as? String ?? ""
                        let location = data["location"] as? String ?? ""
                        let name = data["name"] as? String ?? ""
                        let uid = data["uid"] as? String ?? ""
                        let profileImageUrl = data["profileImageUrl"] as? String ?? ""
                        let postDocumentID = data["postDocumentID"] as? String ?? ""
                        let likedBy = data["likedBy"] as? [String] ?? []
                        let likesCount = data["likesCount"] as? Int ?? 0
                        let comments = data["comments"] as? [[String : Any]] ?? []
                        let timestamp = data["timestamp"] as? FieldValue ?? FieldValue.serverTimestamp()
                        let post = PostModel(
                            postImageURL: postImageURL,
                            caption: caption,
                            location: location,
                            name: name,
                            uid: uid,
                            profileImageUrl: profileImageUrl,
                            postDocumentID: postDocumentID,
                            likedBy: likedBy,
                            likesCount: likesCount,
                            comments: comments,
                            timestamp: timestamp
                        )
                        posts.append(post)
                    }
                    completion(.success(posts))
                }
            }
    }
    
    
    
    // Remove trailing closure from likePost and unlikePost methods
    func likePost(postDocumentID: String, userUID: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let postDocumentRef = db.collection("post").document(postDocumentID)
        
        // Update the 'likedBy' array to add the user's UID and increment the 'likesCount'
        let batch = db.batch()
        batch.updateData(["likedBy": FieldValue.arrayUnion([userUID])], forDocument: postDocumentRef)
        batch.updateData(["likesCount": FieldValue.increment(Int64(1))], forDocument: postDocumentRef)
        
        batch.commit { error in
            if let error = error {
                print("Error liking post: \(error.localizedDescription)")
                completion(false) // Notify that the operation failed
            } else {
                print("Post liked by user with UID: \(userUID)")
                completion(true) // Notify that the operation succeeded
            }
        }
    }
    
    func unlikePost(postDocumentID: String, userUID: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let postDocumentRef = db.collection("post").document(postDocumentID)
        
        // Update the 'likedBy' array to remove the user's UID and decrement the 'likesCount'
        let batch = db.batch()
        batch.updateData(["likedBy": FieldValue.arrayRemove([userUID])], forDocument: postDocumentRef)
        batch.updateData(["likesCount": FieldValue.increment(Int64(-1))], forDocument: postDocumentRef)
        
        batch.commit { error in
            if let error = error {
                print("Error unliking post: \(error.localizedDescription)")
                completion(false) // Notify that the operation failed
            } else {
                print("Post unliked by user with UID: \(userUID)")
                completion(true) // Notify that the operation succeeded
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
    
    
    func addCommentToPost(postDocumentID: String, commentText: String, completion: @escaping (Bool) -> Void) {
        // Get the current user's UID
        if let userUID = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            let postDocumentRef = db.collection("post").document(postDocumentID)
            
            // Create a dictionary to represent the comment
            let commentData: [String: Any] = [
                "uid": userUID,
                "comment": commentText
            ]
            
            // Update the 'comments' array in the post
            let batch = db.batch()
            batch.updateData(["comments": FieldValue.arrayUnion([commentData])], forDocument: postDocumentRef)
            
            batch.commit { error in
                if let error = error {
                    print("Error adding comment to post: \(error.localizedDescription)")
                    completion(false) // Notify that the operation failed
                } else {
                    print("Comment added to post by user with UID: \(userUID)")
                    completion(true) // Notify that the operation succeeded
                }
            }
        } else {
            // Handle the case when the current user is not authenticated
            print("User is not authenticated.")
            completion(false) // Notify that the operation failed
        }
    }
    
    func fetchPostbyPostDocumentID(byPostDocumentID postDocumentID: String, completion: @escaping (Result<PostModel?, Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("post").document(postDocumentID)
            .getDocument { (documentSnapshot, error) in
                if let error = error {
                    print("Error fetching post data: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    let data = documentSnapshot?.data() ?? [:]
                    let postImageURL = data["postImageURL"] as? String ?? ""
                    let caption = data["caption"] as? String ?? ""
                    let location = data["location"] as? String ?? ""
                    let name = data["name"] as? String ?? ""
                    let uid = data["uid"] as? String ?? ""
                    let profileImageUrl = data["profileImageUrl"] as? String ?? ""
                    let likedBy = data["likedBy"] as? [String] ?? []
                    let likesCount = data["likesCount"] as? Int ?? 0
                    let comments = data["comments"] as? [[String: Any]] ?? []
                    let timestamp = data["timestamp"] as? FieldValue ?? FieldValue.serverTimestamp()
                    
                    let post = PostModel(
                        postImageURL: postImageURL,
                        caption: caption,
                        location: location,
                        name: name,
                        uid: uid,
                        profileImageUrl: profileImageUrl,
                        postDocumentID: postDocumentID,
                        likedBy: likedBy,
                        likesCount: likesCount,
                        comments: comments,
                        timestamp: timestamp
                    )
                    completion(.success(post))
                }
            }
    }
    
}
