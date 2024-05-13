//
//  ObjectLifecycleMonitor.swift
//
//
//  Created by Maxim Aliev on 01.05.2024.
//

import Foundation

final class ObjectLifecycleMonitor: NSObject {
    private enum Constants {
        static let leakDetectionThreshold = 3
    }
    
    private var isLeakReported = false
    private var leakDetectionCounter: Int = .zero
    
    weak var object: NSObject?
    weak var host: NSObject?
    weak var responder: NSObject?
    
    init(object: NSObject) {
        super.init()
        self.object = object
        
        NotificationCenter.removeObserver(self, name: .scanForMemoryLeaks)
        NotificationCenter.addObserver(self, selector: #selector(scanForMemoryLeaks), name: .scanForMemoryLeaks)
    }
    
    deinit {
        NotificationCenter.removeObserver(self, name: .scanForMemoryLeaks)
    }
    
    @objc private func scanForMemoryLeaks() {
        guard isLeakReported == false, let object, object.isActive == false else {
            return
        }
        
        leakDetectionCounter += 1
        
        if leakDetectionCounter >= Constants.leakDetectionThreshold {
            reportLeak()
        }
    }
    
    private func reportLeak() {
        isLeakReported = true
        NotificationCenter.post(name: .leakAlert, object: object)
    }
}
