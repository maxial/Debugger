//
//  ViewInspectorConfiguration.swift
//
//
//  Created by Maxim Aliev on 04.05.2024.
//

import Foundation

enum ViewInspectorConfiguration: String, CaseIterable, Identifiable {
    case attributesInspector = "Attributes Inspector"
    case layoutInspector = "Layout Inspector"
    case off = "Off"
    
    var id: String { rawValue }
}
