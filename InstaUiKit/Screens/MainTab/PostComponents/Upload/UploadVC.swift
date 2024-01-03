//
//  UploadVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 30/10/23.
//

import UIKit

protocol UploadVCProtocol : class {
    func setUpMultipleSignImg()
    func shareBtnPressed()
    func backButtonPressed()
}

class UploadVC: UIViewController {
    
    @IBOutlet weak var selectedImg: UIImageView!
    @IBOutlet weak var captionTxtFld: UITextField!
    @IBOutlet weak var locationTxtFld: UITextField!
    @IBOutlet weak var multipleSignImg: UIImageView!
    
    var presenter : UploadVCPresenterProtocol?
    var interactor : UploadVCInteractorProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidload()
    }
   
}

extension UploadVC : UploadVCProtocol {
    
    func setUpMultipleSignImg(){
        if let img = interactor?.img {
            selectedImg.image = img[0]
            multipleSignImg.isHidden = (img.count > 1 ? false : true)
        }
    }
    
    func backButtonPressed(){
        navigationController?.popViewController(animated: true)
    }
    
    func shareBtnPressed(){
        presenter?.uploadPost(view: self, caption: captionTxtFld.text, location: locationTxtFld.text)
    }
    
}

