//
//  DispatchQueue+.swift
//
//
//  Created by Maxim Aliev on 01.05.2024.
//

import Foundation

extension DispatchQueue {
    fileprivate static var _onceTracker = [String]()
    
    static func once(
        _ file: String = #file,
        function: String = #function,
        line: Int = #line,
        block: () -> Void
    ) {
        once(token: file + function + String(line), block: block)
    }
    
    private static func once(token: String, block: () -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
}
