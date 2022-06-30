//
//  notifications.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 13/02/2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import UIKit

class NotificationHelper {
    static var visibleVC: UIViewController? {
        get {
            UIApplication.shared.keyWindow?.visibleViewController // only for single-scene apps
        }
    }
    class func modal(title: String, message: String, actionTitle: String) {
        guard let visibleVC = self.visibleVC else {
            return
        }

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        alertController.addAction(OKAction)
        visibleVC.present(alertController, animated: true, completion: nil)
    }
}

extension UIWindow {
    // Returns the currently visible view controller if any reachable within the window.
    public var visibleViewController: UIViewController? {
        return UIWindow.visibleViewController(from: rootViewController)
    }

    // Recursively follows navigation controllers, tab bar controllers and modal presented view controllers starting
    // from the given view controller to find the currently visible view controller.
    //
    // - Parameters:
    //   - viewController: The view controller to start the recursive search from.
    // - Returns: The view controller that is most probably visible on screen right now.
    public static func visibleViewController(from viewController: UIViewController?) -> UIViewController? {
        switch viewController {
        case let navigationController as UINavigationController:
            return UIWindow.visibleViewController(from: navigationController.visibleViewController ?? navigationController.topViewController)

        case let tabBarController as UITabBarController:
            return UIWindow.visibleViewController(from: tabBarController.selectedViewController)

        case let presentingViewController where viewController?.presentedViewController != nil:
            return UIWindow.visibleViewController(from: presentingViewController?.presentedViewController)

        default:
            return viewController
        }
    }
}
