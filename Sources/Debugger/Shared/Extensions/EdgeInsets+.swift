//
//  EdgeInsets+.swift
//
//
//  Created by Maxim Aliev on 21.04.2024.
//

import SwiftUI

extension EdgeInsets {
    static var zero: EdgeInsets { EdgeInsets(top: .zero, leading: .zero, bottom: .zero, trailing: .zero) }
    
    static func top(_ value: CGFloat) -> EdgeInsets {
        return EdgeInsets(top: value, leading: .zero, bottom: .zero, trailing: .zero)
    }
    
    static func leading(_ value: CGFloat) -> EdgeInsets {
        return EdgeInsets(top: .zero, leading: value, bottom: .zero, trailing: .zero)
    }
    
    static func bottom(_ value: CGFloat) -> EdgeInsets {
        return EdgeInsets(top: .zero, leading: .zero, bottom: value, trailing: .zero)
    }
    
    static func trailing(_ value: CGFloat) -> EdgeInsets {
        return EdgeInsets(top: .zero, leading: .zero, bottom: .zero, trailing: value)
    }
    
    static func padding(_ value: CGFloat) -> EdgeInsets {
        return EdgeInsets(top: value, leading: value, bottom: value, trailing: value)
    }
}

extension UIEdgeInsets {
    static func top(_ value: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: value, left: .zero, bottom: .zero, right: .zero)
    }
    
    static func leading(_ value: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: .zero, left: value, bottom: .zero, right: .zero)
    }
    
    static func bottom(_ value: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: .zero, left: .zero, bottom: value, right: .zero)
    }
    
    static func trailing(_ value: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: .zero, left: .zero, bottom: .zero, right: value)
    }
    
    static func padding(_ value: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: value, left: value, bottom: value, right: value)
    }
}
