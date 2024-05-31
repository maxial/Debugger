//
//  FileHandler.swift
//
//
//  Created by Maxim Aliev on 20.03.2024.
//

import Foundation

class FileHandler: NSObject {
    static func writeTxtFile(text: String, path: String) {
        FileManager.default.createFile(atPath: path, contents: text.data(using: .utf8, allowLossyConversion: true), attributes: nil)
    }
    
    static func writeTxtFileOnDesktop(text: String, fileName: String) {
        let homeUser = NSString(string: "~").expandingTildeInPath.split(separator: "/").dropFirst().first ?? "-"
        let path = "Users/\(homeUser)/Desktop/\(fileName)"
        writeTxtFile(text: text, path: path)
    }
}
