//
//  NotificationVCBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/12/23.
//

import Foundation
import UIKit

final class NotificationVCBuilder {
    
    static var backButtonPressedClosure : (()->())?
    
    static func build() -> UIViewController {
        let storyboard = UIStoryboard.MainTab
        let notificationVC = storyboard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        notificationVC.navigationItem.hidesBackButton = true
        notificationVC.navigationItem.title = "Notification"
        let backButton = UIBarButtonItem(image: UIImage(named: "BackArrow"), style: .plain, target: self, action: #selector(backButtonPressed))
        backButton.tintColor = .black
        notificationVC.navigationItem.leftBarButtonItem = backButton
        NotificationVCBuilder.backButtonPressedClosure = {
            notificationVC.backButtonPressed()
        }
        return notificationVC
    }
    
    @objc static func backButtonPressed() {
        backButtonPressedClosure?()
    }
}
