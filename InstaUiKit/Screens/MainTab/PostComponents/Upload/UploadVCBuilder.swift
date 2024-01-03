//
//  UploadVCBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 03/01/24.
//

import Foundation
import UIKit

final class UploadVCBuilder {
    static func build(img:[UIImage]) -> UIViewController {
        let storyboard = UIStoryboard.MainTab
        let uploadVC = storyboard.instantiateViewController(withIdentifier: "UploadVC") as! UploadVC
        uploadVC.img = img
        return uploadVC
    }
}
