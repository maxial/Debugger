//
//  String+.swift
//
//
//  Created by Maxim Aliev on 01.05.2024.
//

import Foundation

extension String {
    func between(_ left: String, _ right: String) -> String? {
        guard
            let leftRange = range(of: left),
            let rightRange = range(of: right, options: .backwards),
            left != right && leftRange.upperBound < rightRange.lowerBound
        else {
            return nil
        }
        
        return String(self[leftRange.upperBound..<rightRange.lowerBound])
    }
}
