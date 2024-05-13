//
//  FPSCounterService.swift
//
//
//  Created by Maxim Aliev on 26.04.2024.
//

import Foundation

private class FrameNode {
    fileprivate var timestamp: TimeInterval
    
    var next: FrameNode?
    weak var prev: FrameNode?
    
    init(timestamp: TimeInterval) {
        self.timestamp = timestamp
    }
}

final class FPSCounterService {
    private var firstFrame: FrameNode?
    private var lastFrame: FrameNode?
    
    private(set) var fps: Int = .zero
    
    func newFrame(timestamp: TimeInterval) {
        let newFrame = FrameNode(timestamp: timestamp)
        
        guard let lastFrame else {
            self.firstFrame = newFrame
            self.lastFrame = newFrame
            
            fps = 1
            
            return
        }
        
        newFrame.prev = lastFrame
        lastFrame.next = newFrame
        self.lastFrame = newFrame
        
        fps += 1
        
        removeOldFrames()
    }
    
    private func removeOldFrames() {
        guard let lastFrame else {
            return
        }
        
        let minTimestamp = lastFrame.timestamp - 1.0
        
        while let firstFrame = self.firstFrame {
            if firstFrame.timestamp >= minTimestamp {
                break
            }
            
            let nextFrame = firstFrame.next
            nextFrame?.prev = nil
            firstFrame.next = nil
            self.firstFrame = nextFrame
            
            fps -= 1
        }
    }
}
