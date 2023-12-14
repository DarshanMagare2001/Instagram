//
//  AddStoryVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 24/11/23.
//

import UIKit
import YPImagePicker

class AddStoryVC: UIViewController {
    var config = YPImagePickerConfiguration()
    var imgPicker = YPImagePicker()
    override func viewDidLoad() {
        super.viewDidLoad()
        config.library.maxNumberOfItems = 4
        config.screens = [.library, .photo, .video]
        config.library.mediaType = .photoAndVideo
        imgPicker = YPImagePicker(configuration: config)
        self.present(self.imgPicker, animated: true, completion: nil)
        self.imgPicker.didFinishPicking { items, cancelled in
            for item in items {
                switch item {
                case .photo(let photo):
                    print("Photo Selected")
                    
                case .video(let video):
                    print("Video Selected")
                }
            }
            self.imgPicker.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.hidesBackButton = true
        navigationItem.title = "Add Story"
        let backButton = UIBarButtonItem(image: UIImage(named: "BackArrow"), style: .plain, target: self, action: #selector(backButtonPressed))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
}
