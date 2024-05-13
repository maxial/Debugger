//
//  UIViewController+Swizzle.swift
//
//
//  Created by Maxim Aliev on 01.05.2024.
//

import UIKit

extension UIViewController {
    @objc func alterPresent(
        _ viewControllerToPresent: UIViewController,
        animated flag: Bool,
        completion: (() -> Swift.Void)? = nil
    ) {
        self.alterPresent(viewControllerToPresent, animated: flag, completion: completion)
        
        viewControllerToPresent.activateLifecycleMonitor()
    }
    
    @objc func alterViewDidAppear(_ animated: Bool) {
        self.alterViewDidAppear(animated)
        
        self.monitorAllRetainVariables()
    }
}
