//
//  MemoryLeakSnifferService.swift
//  
//
//  Created by Maxim Aliev on 01.05.2024.
//

import UIKit

protocol MemoryLeakSnifferServiceDelegate: AnyObject {
    func didDetectMemoryLeak(with leakedObject: NSObject, leaksCount: Int)
}

final class MemoryLeakSnifferService {
    private enum Constants {
        static let scanFrequency: CGFloat = 1.0
    }
    
    private var timer: Timer?
    private var leaksCount: Int = .zero
    
    weak var delegate: MemoryLeakSnifferServiceDelegate?
    
    var isActive: Bool = false { didSet { switchMemoryLeakSniffer() } }
    
    init() {
        swizzleMethods()
        NotificationCenter.addObserver(self, selector: #selector(leakAlert), name: .leakAlert)
    }
    
    private func switchMemoryLeakSniffer() {
        if isActive {
            startTimer()
        } else {
            stopTimer()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        leaksCount = .zero
    }
    
    private func startTimer() {
        stopTimer()
        
        timer = Timer.scheduledTimer(
            timeInterval: Constants.scanFrequency,
            target: self,
            selector: #selector(scanForMemoryLeaks),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc private func scanForMemoryLeaks()  {
        NotificationCenter.post(name: .scanForMemoryLeaks)
    }
    
    @objc private func leakAlert(notification: Notification) {
        guard let leakedObject = notification.object as? NSObject else {
            return
        }
        
        leaksCount += 1
        
        delegate?.didDetectMemoryLeak(with: leakedObject, leaksCount: leaksCount)
    }
    
    private func swizzleMethods() {
        DispatchQueue.once {
            UINavigationController.swizzle(
                originalSelector: #selector(UINavigationController.pushViewController(_:animated:)),
                with: #selector(UINavigationController.alterPushViewController(_:animated:))
            )
            UIView.swizzle(
                originalSelector: #selector(UIView.didMoveToSuperview),
                with: #selector(UIView.alterDidMoveToSuperview)
            )
            UIViewController.swizzle(
                originalSelector: #selector(UIViewController.present(_:animated:completion:)),
                with: #selector(UIViewController.alterPresent(_:animated:completion:))
            )
            UIViewController.swizzle(
                originalSelector: #selector(UIViewController.viewDidAppear(_:)),
                with: #selector(UIViewController.alterViewDidAppear(_:))
            )
        }
    }
}
