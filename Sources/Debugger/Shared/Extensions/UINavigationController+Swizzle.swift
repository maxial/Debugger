//
//  UINavigationController+Swizzle.swift
//
//
//  Created by Maxim Aliev on 01.05.2024.
//

import UIKit

extension UINavigationController {
    @objc func alterPushViewController(_ viewController: UIViewController, animated: Bool) {
        self.alterPushViewController(viewController, animated: animated)
        
        viewController.activateLifecycleMonitor()
    }
}
