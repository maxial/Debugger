//
//  NotificationCenter+.swift
//  
//
//  Created by Maxim Aliev on 01.05.2024.
//

import Foundation

extension NotificationCenter {
    static func addObserver(_ observer: Any, selector: Selector, name: Notification.Name) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: nil)
    }
    
    static func removeObserver(_ observer: Any, name: Notification.Name) {
        NotificationCenter.default.removeObserver(observer, name: name, object: nil)
    }
    
    static func post(name: Notification.Name, object: Any? = nil) {
        NotificationCenter.default.post(name: name, object: object)
    }
}
