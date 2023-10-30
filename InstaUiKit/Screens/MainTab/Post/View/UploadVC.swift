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
            if let img = self.img, let caption = self.captionTxtFld.text, let location = self.locationTxtFld.text {
                PostViewModel.shared.uploadImageToFirebaseStorage(image: img, caption: caption, location: location)
            }
        },
                                noHandler: { _ in
            
            print("User selected No")
        }
        )
    }
    
}


