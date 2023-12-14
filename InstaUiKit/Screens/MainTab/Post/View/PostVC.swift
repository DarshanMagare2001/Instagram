//
//  PostVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit
import YPImagePicker

class PostVC: UIViewController {
    @IBOutlet weak var imgForPost: UIImageView!
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var imageView: UIView!
    var config = YPImagePickerConfiguration()
    var imgPicker = YPImagePicker()
    override func viewDidLoad() {
        super.viewDidLoad()
        config.library.maxNumberOfItems = 4
        config.screens = [.library,.photo]
        config.library.mediaType = .photoAndVideo
        imgPicker = YPImagePicker(configuration: config)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        presentImagePicker()
    }
    
    func presentImagePicker() {
        if let topViewController = UIApplication.topViewController() {
            if topViewController.presentedViewController is YPImagePicker {
                return
            }
        }
        imgPicker.didFinishPicking { [weak self] items , _ in
            for item in items {
                switch item {
                case .photo(let photo):
                    let image = photo.image
                    let storyboard = UIStoryboard.MainTab
                    let destinationVC = storyboard.instantiateViewController(withIdentifier: "UploadVC") as! UploadVC
                    destinationVC.img = image
                    self?.navigationController?.pushViewController(destinationVC, animated: true)
                case .video(let video):
                    print(video)
                }
            }
        }
        self.addChild(imgPicker)
        self.view.addSubview(imgPicker.view)
        imgPicker.didMove(toParent: self)
    }
    
}
