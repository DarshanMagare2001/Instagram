//
//  Alert.swift
//  InstaUiKit
//
//  Created by IPS-161 on 27/10/23.
//

import UIKit

class Alert {
    static let shared = Alert()
    private init() {}

    func alertOk(title: String, message: String, presentingViewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        presentingViewController.present(alertController, animated: true, completion: nil)
    }
}

