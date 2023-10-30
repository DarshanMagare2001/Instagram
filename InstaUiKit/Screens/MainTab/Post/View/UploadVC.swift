//
//  UploadVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 30/10/23.
//

import UIKit

class UploadVC: UIViewController {
    @IBOutlet weak var selectedImg: UIImageView!
    @IBOutlet weak var captionTxtFld: UITextField!
    @IBOutlet weak var locationTxtFld: UITextField!
    var img : UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let img = img {
            selectedImg.image = img
        }
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareBtnPressed(_ sender: UIButton) {
        Alert.shared.alertYesNo(title: "Confirmation", message: "Are you sure you want to Upload Photo?", presentingViewController: self,
                                yesHandler: { _ in
            
            print("User selected Yes")
            LoaderVCViewModel.shared.showLoader()
            if let img = self.img, let caption = self.captionTxtFld.text, let location = self.locationTxtFld.text {
                PostViewModel.shared.uploadImageToFirebaseStorage(image: img, caption: caption, location: location){ value in
                    if value {
                        LoaderVCViewModel.shared.hideLoader()
                        Alert.shared.alertOk(title: "Success!", message: "Your Photo uploaded successfully.", presentingViewController: self)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                            self.navigationController?.popViewController(animated: true)
                        }
                    }else{
                        LoaderVCViewModel.shared.hideLoader()
                        Alert.shared.alertOk(title: "Error!", message: "Your Photo not uploaded.", presentingViewController: self)
                    }
                    
                }
            }
        },
                                noHandler: { _ in
            
            print("User selected No")
        }
        )
    }
    
}


