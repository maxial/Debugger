//
//  PropertyWrapper.swift
//
//
//  Created by Maxim Aliev on 01.05.2024.
//

import Foundation

final class PropertyWrapper: NSObject {
    private var property: objc_property_t
    private var attrString: UnsafePointer<CChar> { property_getAttributes(property)! }
    
    var isStrong: Bool { String(cString: attrString).contains("&") }
    var type: AnyClass? { getType() }
    var name: String { String(cString: property_getName(property)) }
    
    init(property: objc_property_t) {
        self.property = property
        super.init()
    }
    
    private func getType() -> AnyClass? {
        let type = String(cString: attrString)
            .components(separatedBy: ",").first?
            .between("@\"", "\"")
        
        return NSClassFromString(type ?? "")
    }
}
