//
//  NSObject+LifecycleMonitor.swift
//
//
//  Created by Maxim Aliev on 01.05.2024.
//

import UIKit

extension NSObject {
    private static var _lifecycleMonitorKey: UInt8 = 21
    private static let _monitoringDepth = 5
    
    var monitor: ObjectLifecycleMonitor? {
        get { getAssociatedObject(self, key: &NSObject._lifecycleMonitorKey) }
        set { setAssociatedObject(self, key: &NSObject._lifecycleMonitorKey, value: newValue) }
    }
    
    var isActive: Bool { getIsActive() }
    
    @discardableResult
    func activateLifecycleMonitor() -> Bool {
        guard monitor == nil, isSystemClass(classForCoder) == false else {
            return false
        }
        
        if let view = self as? UIView, view.superview == nil {
            return false
        } else if
            let viewController = self as? UIViewController,
            viewController.navigationController == nil && viewController.presentingViewController == nil
        {
            return false
        }
        
        monitor = ObjectLifecycleMonitor(object: self)
        return true
    }
    
    func monitorAllRetainVariables(level: Int = .zero) {
        guard level < NSObject._monitoringDepth else {
            return
        }
        
        var propertyNames: [String] = []
        
        if isSystemClass(classForCoder) == false {
            propertyNames.append(contentsOf: getAllPropertyNames(for: classForCoder))
        }
        
        if let superclass, isSystemClass(superclass) {
            propertyNames.append(contentsOf: getAllPropertyNames(for: superclass))
        }
        
        if let supersuperclass = superclass?.superclass(), isSystemClass(supersuperclass) {
            propertyNames.append(contentsOf: getAllPropertyNames(for: supersuperclass))
        }
        
        for propertyName in propertyNames {
            guard propertyName != "tabBarObservedScrollView", let object = value(forKey: propertyName) as? NSObject else {
                continue
            }
            
            let isActivated = object.activateLifecycleMonitor()
            
            if isActivated {
                object.monitor?.host = self
                object.monitorAllRetainVariables(level: level + 1)
            }
        }
    }
    
    private func getAllPropertyNames(for cls: AnyClass) -> [String] {
        let count = UnsafeMutablePointer<UInt32>.allocate(capacity: .zero)
        let properties = class_copyPropertyList(cls, count)
        
        defer { free(properties) }
        
        if Int(count[.zero]) == .zero {
            return []
        }
        
        var result: [String] = []
        for i in .zero..<Int(count[.zero]) {
            guard let property = properties?[i] else {
                continue
            }
            
            let propertyWrapper = PropertyWrapper(property: property)
            
            guard let type = propertyWrapper.type, type != classForCoder, propertyWrapper.isStrong else {
                continue
            }
            
            result.append(propertyWrapper.name)
        }
        
        return result
    }
    
    private func getIsActive() -> Bool {
        if isKind(of: UIViewController.classForCoder()) {
            if let viewController = self as? UIViewController {
                return isActive(viewController)
            }
        } else if isKind(of: UIView.classForCoder()) {
            if let view = self as? UIView {
                return isActive(view)
            }
        }
        return isActive(self)
    }
    
    private func isActive(_ controller: UIViewController) -> Bool {
        guard
            controller.view.window != nil ||
            controller.navigationController != nil ||
            controller.presentingViewController != nil
        else {
            return false
        }
        
        return true
    }
    
    private func isActive(_ view: UIView) -> Bool {
        var view = view
        while let superview = view.superview {
            view = superview
        }
        
        if view is UIWindow {
            return true
        }
        
        if view.monitor?.responder == nil {
            var responder = view.next
            while let nextResponder = responder?.next {
                if nextResponder.isKind(of: UIViewController.classForCoder()) {
                    responder = nextResponder
                    break
                }
                responder = nextResponder
            }
            view.monitor?.responder = responder
        }
        
        return view.monitor?.responder?.isKind(of: UIViewController.classForCoder()) ?? false
    }
    
    private func isActive(_ object: NSObject) -> Bool {
        return object.monitor?.host != nil
    }
}
