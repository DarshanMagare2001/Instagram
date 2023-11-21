//
//  HomeVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit
import SwiftUI
import FirebaseAuth
import SkeletonView

class HomeVC: UIViewController {
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var storiesCollectionView: UICollectionView!
    @IBOutlet weak var userImg: CircleImageView!
    var imgURL : URL?
    var userName : String?
    var allPost = [PostModel]()
    var allUniqueUsersArray = [UserModel]()
    var uid : String?
    var refreshControll = UIRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "FeedCell", bundle: nil)
        feedTableView.register(nib, forCellReuseIdentifier: "FeedCell")
        self.view.showAnimatedGradientSkeleton()
        refreshControll.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        feedTableView.addSubview(refreshControll)
        if let currentUid = Auth.auth().currentUser?.uid {
            uid = currentUid
        }
        DispatchQueue.main.async {
            self.updateUI()
            self.storiesCollectionView.isSkeletonable = true
            self.storiesCollectionView.showAnimatedGradientSkeleton()
            self.feedTableView.isSkeletonable = true
            self.feedTableView.showAnimatedGradientSkeleton()
        }
        
        let fcmToken = "cOxUfk1p9ky3r-y1vgdyZz:APA91bGJGXUkUHzAjYr2yNDXDdEQFzBUKWXSzpTih5uLyYlsW2KAkzUnj2FzGdDgmYpQgEWWb1iM7avrCHAvNukp22epq6i2FO2pljzCUTyGGEUK193_rRBMKHpjaaJ6NuJSqzZbvrPk"
        sendPushNotification(to: fcmToken, title: "InstaUiKit", body: "Hi Darshan")
     
    }
   
    func sendPushNotification(to fcmToken: String, title: String, body: String) {
        guard let url = URL(string: "https://fcm.googleapis.com/fcm/send") else {
            print("Invalid URL")
            return
        }

        let serverKey = "AAAAVisTDNY:APA91bHsr0doWbLx0HC9K1Wr54BEWtDdD8unOhppRrg8IONF3kl0OMr3zUjbv7MooIvkF630yP1A95QvEIXDhGF-5P3kb0Koh_FzjmVSKk7hok8yvHLUKwfbZpN1XxiFbRQnvpBgvKU1"
        let headers: [String: String] = [
            "Content-Type": "application/json",
            "Authorization": "key=\(serverKey)"
        ]

        let notification = [
            "title": title,
            "body": body
        ]

        let payload: [String: Any] = [
            "to": fcmToken,
            "notification": notification
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                } else if let data = data {
                    if let httpResponse = response as? HTTPURLResponse {
                        if (200...299).contains(httpResponse.statusCode) {
                            print("Notification sent successfully.")
                        } else {
                            print("Failed to send notification. Status Code: \(httpResponse.statusCode)")
                        }
                    }
                    let responseString = String(data: data, encoding: .utf8)
                    print("Response data: \(responseString ?? "")")
                }
            }
            task.resume()
        } catch {
            print("Error serializing JSON: \(error)")
        }
    }
    
   

    
    @objc func refresh(send:UIRefreshControl){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.updateUI()
            self.storiesCollectionView.isSkeletonable = true
            self.storiesCollectionView.showAnimatedGradientSkeleton()
            self.feedTableView.isSkeletonable = true
            self.feedTableView.showAnimatedGradientSkeleton()
            self.refreshControll.endRefreshing()
        }
    }
    
    
    @IBAction func cameraBtnPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard.MainTab
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "CameraVC") as! CameraVC
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    @IBAction func directMsgBtnPressed(_ sender: UIButton) {
        Navigator.shared.navigate(storyboard: UIStoryboard.MainTab, destinationVCIdentifier: "DirectMsgVC") { destinationVC in
            if let destinationVC = destinationVC {
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
    }
    
}

extension HomeVC {
    func updateUI(){
        
        Data.shared.getData(key: "ProfileUrl") { (result: Result<String?, Error>) in
            switch result {
            case .success(let urlString):
                if let url = urlString {
                    if let imageURL = URL(string: url) {
                        self.imgURL = imageURL
                    } else {
                        print("Invalid URL: \(url)")
                    }
                } else {
                    print("URL is nil or empty")
                }
            case .failure(let error):
                print("Error loading image: \(error)")
            }
        }
        
        Data.shared.getData(key: "Name") { (result: Result<String, Error>) in
            switch result{
            case .success(let data):
                print(data)
                self.userName = data
            case .failure(let error):
                print(error)
            }
        }
        
        PostViewModel.shared.fetchAllPosts { result in
            switch result {
            case .success(let images):
                // Handle the images
                print("Fetched images: \(images)")
                DispatchQueue.main.async {
                    self.allPost = images
                    self.feedTableView.stopSkeletonAnimation()
                    self.view.stopSkeletonAnimation()
                    self.feedTableView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
                    self.feedTableView.reloadData()
                }

            case .failure(let error):
                // Handle the error
                print("Error fetching images: \(error)")
            }
        }
        
        if let url = imgURL {
            ImageLoader.loadImage(for: url, into: userImg, withPlaceholder: UIImage(systemName: "person.fill"))
        }
        
        FetchUserInfo.shared.fetchUniqueUsersFromFirebase { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async{
                    print(data)
                    self.allUniqueUsersArray = data
                    self.storiesCollectionView.stopSkeletonAnimation()
                    self.view.stopSkeletonAnimation()
                    self.storiesCollectionView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
                    self.storiesCollectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
}

extension HomeVC: SkeletonTableViewDataSource, SkeletonTableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPost.count
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int{
        10
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "FeedCell"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
        let post = allPost[indexPath.row]
        DispatchQueue.main.async {
            ProfileViewModel.shared.fetchUserData(uid: post.uid) { result in
                switch result {
                case.success(let data):
                    if let imgUrl = data.imageUrl , let name = data.name {
                        ImageLoader.loadImage(for: URL(string:imgUrl), into: cell.userImg1, withPlaceholder: UIImage(systemName: "person.fill"))
                        ImageLoader.loadImage(for: URL(string:imgUrl), into: cell.userImg2, withPlaceholder: UIImage(systemName: "person.fill"))
                        cell.userName.text = name
                    }
                case.failure(let error):
                    print(error)
                }
            }
        }
        ImageLoader.loadImage(for: URL(string: post.postImageURL), into: cell.postImg, withPlaceholder: UIImage(systemName: "person.fill"))
        cell.postLocationLbl.text = post.location
        cell.postCaption.text = post.caption
        cell.totalLikesCount.text = "\(post.likesCount) Likes"
        
        if let randomLikedByUID = post.likedBy.randomElement() {
            ProfileViewModel.shared.fetchUserData(uid: randomLikedByUID) { result in
                switch result {
                case .success(let data):
                    if let name = data.name {
                        cell.likedByLbl.text = "Liked by \(name) and \(Int(post.likedBy.count - 1)) others."
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        if let uid = uid {
            if (post.likedBy.contains(uid)){
                cell.isLiked = true
                let imageName = cell.isLiked ? "heart.fill" : "heart"
                cell.likeBtn.setImage(UIImage(systemName: imageName), for: .normal)
                cell.likeBtn.tintColor = cell.isLiked ? .red : .black
            }else{
                cell.isLiked = false
                let imageName = cell.isLiked ? "heart.fill" : "heart"
                cell.likeBtn.setImage(UIImage(systemName: imageName), for: .normal)
                cell.likeBtn.tintColor = cell.isLiked ? .red : .black
            }
            
            cell.likeBtnTapped = { [weak self] in
                if cell.isLiked {
                    PostViewModel.shared.unlikePost(postDocumentID: post.postDocumentID, userUID: uid) { success in
                        if success {
                            // Update the UI: Set the correct image for the like button
                            cell.isLiked = false
                            let imageName = cell.isLiked ? "heart.fill" : "heart"
                            cell.likeBtn.setImage(UIImage(systemName: imageName), for: .normal)
                            cell.likeBtn.tintColor = cell.isLiked ? .red : .black
                        }
                    }
                } else {
                    PostViewModel.shared.likePost(postDocumentID: post.postDocumentID, userUID: uid) { success in
                        if success {
                            // Update the UI: Set the correct image for the like button
                            cell.isLiked = true
                            let imageName = cell.isLiked ? "heart.fill" : "heart"
                            cell.likeBtn.setImage(UIImage(systemName: imageName), for: .normal)
                            cell.likeBtn.tintColor = cell.isLiked ? .red : .black
                        }
                    }
                }
            }
        }
        
        cell.commentsBtnTapped = { [weak self] in
            let storyboard = UIStoryboard.Common
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "CommentsVC") as! CommentsVC
            destinationVC.allPost = post
            self?.navigationController?.pushViewController(destinationVC, animated: true)
        }
        return cell
    }
    
}


extension HomeVC: SkeletonCollectionViewDataSource  , SkeletonCollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        allUniqueUsersArray.count
    }
    
    func collectionSkeletonView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "StoriesCell"
    }
    
    func collectionView (_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoriesCell", for: indexPath) as! StoriesCell
        if let uid = allUniqueUsersArray[indexPath.row].uid,
           let name = allUniqueUsersArray[indexPath.row].name,
           let imgUrl = allUniqueUsersArray[indexPath.row].imageUrl{
            DispatchQueue.main.async {
                ImageLoader.loadImage(for: URL(string: imgUrl), into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                cell.userName.text = name
            }
        }
        return cell
    }
    
    
}


