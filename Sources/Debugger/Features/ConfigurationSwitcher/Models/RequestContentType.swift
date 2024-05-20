//
//  RequestContentType.swift
//
//
//  Created by Maxim Aliev on 23.04.2024.
//

import Foundation

enum RequestContentType {
    case applicationJson
    case xWwwFormUrlencoded
    case multipartFormData
    case unknown(String)
    
    init?(rawValue: String?) {
        guard let rawValue else {
            return nil
        }
        
        switch rawValue {
        case "application/json":
            self = .applicationJson
        case "application/x-www-form-urlencoded":
            self = .xWwwFormUrlencoded
        default:
            if rawValue.contains("multipart/form-data") {
                self = .multipartFormData
            } else {
                self = .unknown(rawValue)
            }
        }
    }
}
