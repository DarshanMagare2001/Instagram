//
//  UploadVCInteractor.swift
//  InstaUiKit
//
//  Created by IPS-161 on 03/01/24.
//

import Foundation
import UIKit

protocol UploadVCInteractorProtocol {
    var img : [UIImage]? { get set }
    func uploadPost(view:UIViewController,caption:String?,location:String?)
}

class UploadVCInteractor {
    var img : [UIImage]?
}

extension UploadVCInteractor : UploadVCInteractorProtocol {
    func uploadPost(view:UIViewController,caption:String?,location:String?){
        Alert.shared.alertYesNo(title: "Confirmation", message: "Are you sure you want to Upload Photo?", presentingViewController: view,
                                yesHandler: { _ in
            print("User selected Yes")
            MessageLoader.shared.showLoader(withText: "Please wait Uploading..")
            if let img = self.img, let caption = caption, let location = location {
                PostViewModel.shared.uploadImagesToFirebaseStorage(images: img, caption: caption, location: location){ value in
                    if value {
                        MessageLoader.shared.hideLoader()
                        Alert.shared.alertOk(title: "Success!", message: "Your Photo uploaded successfully.", presentingViewController: view){ _ in
                            view.navigationController?.popViewController(animated: true)
                        }
                    }else{
                        MessageLoader.shared.hideLoader()
                        Alert.shared.alertOk(title: "Error!", message: "Your Photo not uploaded.", presentingViewController: view){ _ in}
                    }
                }
            }
        },noHandler: { _ in
            print("User selected No")
        }
        )
    }
}
