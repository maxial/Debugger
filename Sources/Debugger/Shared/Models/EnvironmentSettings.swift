//
//  EnvironmentSettings.swift
//
//
//  Created by Maxim Aliev on 14.03.2024.
//

import Foundation

struct EnvironmentSettings {
    var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
}
