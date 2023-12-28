//
//  DirectMsgVCBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/12/23.
//

import Foundation
import UIKit

final class DirectMsgVCBuilder {
    static func build() -> UIViewController {
        let storyboard = UIStoryboard.MainTab
        let directMsgVC = storyboard.instantiateViewController(withIdentifier: "DirectMsgVC") as! DirectMsgVC
//        notificationVC.title = "Chats"
        return directMsgVC
    }
}

