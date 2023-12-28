//
//  NotificationVCBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/12/23.
//

import Foundation
import UIKit

final class NotificationVCBuilder {
    static func build() -> UIViewController {
        let storyboard = UIStoryboard.MainTab
        let notificationVC = storyboard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
//        notificationVC.title = "Notification"
        return notificationVC
    }
}
