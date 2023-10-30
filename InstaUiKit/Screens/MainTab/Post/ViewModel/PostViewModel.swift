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
    
    
    func uploadImageToFirebaseStorage(image: UIImage, caption: String, location: String) {
        let imageName = "\(Int(Date().timeIntervalSince1970)).jpg"
        let storageRef = Storage.storage().reference().child("images/\(imageName)")
        
        if let imageData = image.jpegData(compressionQuality: 0.5) {
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
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
                                "uid": uid
                            ]
                            
                            db.collection("images").addDocument(data: imageDocData) { (error) in
                                if let error = error {
                                    print("Error adding document: \(error)")
                                } else {
                                    print("Document added successfully")
                                }
                            }
                        } else {
                            print("Error getting image download URL: \(error?.localizedDescription ?? "")")
                        }
                    }
                }
            }
        }
    }
    
    
}
