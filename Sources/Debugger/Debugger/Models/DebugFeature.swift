//
//  DebugFeature.swift
//
//
//  Created by Maxim Aliev on 15.03.2024.
//

import Foundation

enum DebugFeature: Identifiable {
    var id: String { name }
    
    case configurationSwitcher
    case networkSniffer
    case viewInspector
    case animationControl
    case systemDebugger
    
    var name: String {
        switch self {
        case .configurationSwitcher:
            return "Configuration"
        case .networkSniffer:
            return "Network Sniffer"
        case .viewInspector:
            return "View Inspector"
        case .animationControl:
            return "Animations"
        case .systemDebugger:
            return "System"
        }
    }
}
