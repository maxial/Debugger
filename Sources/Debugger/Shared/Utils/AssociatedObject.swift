//
//  File.swift
//  
//
//  Created by Maxim Aliev on 01.05.2024.
//

import Foundation

func getAssociatedObject<T>(_ object: Any, key: UnsafeRawPointer) -> T? {
    guard let object = objc_getAssociatedObject(object, key) as? T else {
        return nil
    }
    return object
}

func setAssociatedObject<T>(
    _ object: Any,
    key: UnsafeRawPointer,
    value: T,
    policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC
) {
    objc_setAssociatedObject(object, key, value, policy)
}
