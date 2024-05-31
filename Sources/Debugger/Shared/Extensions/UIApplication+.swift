//
//  UIApplication+.swift
//
//
//  Created by Maxim Aliev on 21.03.2024.
//

import UIKit

extension UIApplication {
    static var animationSpeed: Float {
        get { UIWindow.keyWindow?.layer.speed ?? 1 }
        set { UIWindow.allDebuggableWindows.forEach { $0.layer.speed = newValue } }
    }
}
