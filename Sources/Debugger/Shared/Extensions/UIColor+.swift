//
//  UIColor+.swift
//
//
//  Created by Maxim Aliev on 11.05.2024.
//

import UIKit

extension UIColor {
    var hex: String { getHex() }
    
    private func getHex() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let redInt = Int(red * 255)
        let greenInt = Int(green * 255)
        let blueInt = Int(blue * 255)

        return String(format: "#%02lX%02lX%02lX", redInt, greenInt, blueInt)
    }
}
