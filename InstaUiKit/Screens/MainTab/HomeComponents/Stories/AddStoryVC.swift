//
//  AddStoryVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 24/11/23.
//
import UIKit
import YPImagePicker


class AddStoryVC: UIViewController {
    @IBOutlet weak var mainView: UIView!
    var config = YPImagePickerConfiguration()
    var imgPicker = YPImagePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        config.library.maxNumberOfItems = 4
        config.screens = [.library, .photo, .video]
        config.library.mediaType = .photoAndVideo
        imgPicker = YPImagePicker(configuration: config)
        presentImagePicker()
    }

    func presentImagePicker() {
        // Check if the image picker is already presented
        if let topViewController = UIApplication.topViewController() {
            if topViewController.presentedViewController is YPImagePicker {
                return
            }
        }

        // Present the image picker on the mainView
        imgPicker.didFinishPicking { [weak self] items, cancelled in
            for item in items {
                switch item {
                case .photo(let photo):
                    print("Photo Selected")
                case .video(let video):
                    print("Video Selected")
                }
            }
            self?.navigationController?.popViewController(animated: true)
        }

        // Add YPImagePicker as a subview to mainView
        imgPicker.view.frame = mainView.bounds
        mainView.addSubview(imgPicker.view)

        self.addChild(imgPicker)
        imgPicker.didMove(toParent: self)
    }
}
