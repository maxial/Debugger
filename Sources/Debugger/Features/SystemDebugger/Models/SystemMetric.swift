//
//  SystemMetric.swift
//
//
//  Created by Maxim Aliev on 25.04.2024.
//

import Foundation

enum SystemMetricType: String, CaseIterable {
    case fps = "FPS"
    case cpuUsage = "CPU Usage"
    case memoryUsage = "RAM Usage"
    case leaksCount = "Memory Leaks"
    
    var id: String { rawValue }
    
    var widgetPrefix: String {
        switch self {
        case .fps:
            return "FPS: "
        case .cpuUsage:
            return "CPU: "
        case .memoryUsage:
            return "RAM: "
        case .leaksCount:
            return "Leaks: "
        }
    }
    
    var widgetSeparator: String {
        switch self {
        case .fps:
            return " "
        case .cpuUsage:
            return "\n"
        case .memoryUsage:
            return "\n"
        case .leaksCount:
            return ""
        }
    }
}

struct SystemMetric: Identifiable {
    let type: SystemMetricType
    let value: String
    
    var id: String { type.rawValue }
}
