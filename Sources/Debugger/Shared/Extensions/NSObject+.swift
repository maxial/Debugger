//
//  NSObject+.swift
//
//
//  Created by Maxim Aliev on 01.05.2024.
//

import Foundation

extension NSObject {
    static func swizzle(
        originalSelector: Selector,
        with alterSelector: Selector,
        in alterClass: AnyClass? = nil,
        isClassMethod: Bool = false
    ) {
        let targetClass: AnyClass = alterClass ?? self.classForCoder()
        let affectedClass: AnyClass = isClassMethod ? (object_getClass(targetClass) ?? targetClass) : targetClass
        
        guard
            let originalMethod = class_getInstanceMethod(affectedClass, originalSelector),
            let alterMethod = class_getInstanceMethod(affectedClass, alterSelector)
        else {
            return
        }
        
        method_exchangeImplementations(originalMethod, alterMethod)
    }
    
    func isSystemClass(_ cls: AnyClass) -> Bool {
        let bundle = Bundle(for: cls)
        let bundleIdentifier = bundle.bundleIdentifier ?? ""
        
        return bundle.bundlePath.hasSuffix("/usr/lib") || bundleIdentifier.hasPrefix("com.apple.")
    }
}
