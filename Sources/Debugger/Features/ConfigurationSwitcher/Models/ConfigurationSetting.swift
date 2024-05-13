//
//  ConfigurationSetting.swift
//  
//
//  Created by Maxim Aliev on 31.03.2024.
//

import Foundation

enum ConfigurationSetting {
    case defaultFlag
    case baseURL
    
    var key: String {
        switch self {
        case .defaultFlag:
            return "DEFAULT"
        case .baseURL:
            return "BASEURL"
        }
    }
}
