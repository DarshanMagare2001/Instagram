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
    
    
    func uploadImageToFirebaseStorage(image: UIImage, caption: String, location: String , name : String, completionHandler : @escaping(Bool)->Void) {
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
                            
                            // Include UID in the document data
                            let imageDocData: [String: Any] = [
                                "imageURL": downloadURL.absoluteString,
                                "caption": caption,
                                "location": location,
                                "name": name,
                                "uid": uid
                            ]
                            
                            db.collection("images").addDocument(data: imageDocData) { (error) in
                                if let error = error {
                                    print("Error adding document: \(error)")
                                    completionHandler(false)
                                } else {
                                    print("Document added successfully")
                                    completionHandler(true)
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
    
    func fetchImageData(completion: @escaping (Result<[ImageModel], Error>) -> Void) {
        let db = Firestore.firestore()
        
        // Get the UID of the currently authenticated user
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User is not authenticated.")
            return
        }
        
        // Query the "images" collection with a filter for the current user's UID
        db.collection("images")
            .whereField("uid", isEqualTo: uid)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching images: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    var images: [ImageModel] = []
                    for document in querySnapshot!.documents {
                        if let imageURL = document["imageURL"] as? String,
                           let caption = document["caption"] as? String,
                           let name = document["name"] as? String,
                           let location = document["location"] as? String {
                            let image = ImageModel(imageURL: imageURL, caption: caption, location: location, uid: uid, name: name)
                            images.append(image)
                        }
                    }
                    completion(.success(images))
                }
            }
    }
    
    
    func fetchAllPosts(completion: @escaping (Result<[ImageModel], Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("images")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching images: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    var images: [ImageModel] = []
                    
                    for document in querySnapshot!.documents {
                        if let imageURL = document["imageURL"] as? String,
                           let caption = document["caption"] as? String,
                           let location = document["location"] as? String,
                           let name = document["name"] as? String,
                           let uid = document["uid"] as? String {
                            let image = ImageModel(imageURL: imageURL, caption: caption, location: location, uid: uid, name: name)
                            images.append(image)
                        }
                    }
                    completion(.success(images))
                }
            }
    }
    
    
    
}
