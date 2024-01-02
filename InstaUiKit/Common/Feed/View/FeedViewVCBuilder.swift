//
//  FeedViewVCBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 02/01/24.
//

import Foundation
import UIKit

final class FeedViewVCBuilder {
    static func build(allPost:[PostAllDataModel]) -> UIViewController {
        let storyboard = UIStoryboard.Common
        let feedViewVC = storyboard.instantiateViewController(withIdentifier: "FeedViewVC") as! FeedViewVC
        feedViewVC.allPost = allPost
        return feedViewVC
    }
}
