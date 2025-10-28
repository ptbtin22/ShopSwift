//
//  UIViewController+Extensions.swift
//  GitHub Followers
//
//  Created by Tín Phạm on 16/10/25.
//

import UIKit

extension UIViewController {

    func presentAlertOnMainThread(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let alertVC = AlertViewController(title: title, message: message, buttonTitle: buttonTitle)
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            self.present(alertVC, animated: true)
        }
    }

}
