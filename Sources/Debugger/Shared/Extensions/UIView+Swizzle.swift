//
//  UIView+Swizzle.swift
//
//
//  Created by Maxim Aliev on 01.05.2024.
//

import UIKit

extension UIView {
    @objc func alterDidMoveToSuperview() {
        self.alterDidMoveToSuperview()
        
        var node = self.next
        while let current = node, current.monitor == nil {
            node = current.next
        }
        
        if node?.monitor != nil {
            self.activateLifecycleMonitor()
        }
    }
    
    @objc func alterLayoutSubviews() {
        self.alterLayoutSubviews()
        
        updateConfiguration()
    }
}
