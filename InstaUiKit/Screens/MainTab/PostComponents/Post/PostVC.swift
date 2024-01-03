//
//  PostVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit
import YPImagePicker

protocol PostVCProtocol : class {
    func presentImagePicker()
}

class PostVC: UIViewController {
    @IBOutlet weak var imgForPost: UIImageView!
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var mainView: UIView!
    var presenter : PostVCPresenterProtocol?
    var config = YPImagePickerConfiguration()
    var imgPicker = YPImagePicker()
    let disPatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidload()
        config.library.maxNumberOfItems = 4
        config.screens = [.library,.photo]
        config.library.mediaType = .photoAndVideo
        imgPicker = YPImagePicker(configuration: config)
    }
    
    private func gotoUploadVC(images:[UIImage]){
        let storyboard = UIStoryboard.MainTab
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "UploadVC") as! UploadVC
        destinationVC.img = images
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
}

extension PostVC : PostVCProtocol {
    
    func presentImagePicker(){
        // Check if the image picker is already presented
        if let topViewController = UIApplication.topViewController() {
            if topViewController.presentedViewController is YPImagePicker {
                return
            }
        }
        
        imgPicker.didFinishPicking { [weak self] items , _ in
            var images = [UIImage]()
            for item in items {
                self?.disPatchGroup.enter()
                switch item {
                case .photo(let photo):
                    let image = photo.image
                    images.append(image)
                    self?.disPatchGroup.leave()
                case .video(let video):
                    print(video)
                }
            }
            
            self?.disPatchGroup.notify(queue: .main) {
                guard  images.count > 0 else {return}
                self?.gotoUploadVC(images:images)
            }
            
        }
        
        // Add YPImagePicker as a subview to mainView
        imgPicker.view.frame = mainView.bounds
        mainView.addSubview(imgPicker.view)
        
        self.addChild(imgPicker)
        imgPicker.didMove(toParent: self)
    }
    
}


