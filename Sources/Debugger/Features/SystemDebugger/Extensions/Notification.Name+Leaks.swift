//
//  Notification.Name+Leaks.swift
//
//
//  Created by Maxim Aliev on 01.05.2024.
//

import Foundation

extension Notification.Name {
    static let scanForMemoryLeaks = NSNotification.Name("ScanForMemoryLeaks")
    static let leakAlert = NSNotification.Name("LeakAlert")
}
