//
//  ConfigurationItemViewModel.swift
//  
//
//  Created by Maxim Aliev on 07.04.2024.
//

import SwiftUI

final class ConfigurationItemViewModel: ObservableObject {
    let configuration: DebuggerConfiguration
    let isSelected: Bool
    
    init(configuration: DebuggerConfiguration, isSelected: Bool) {
        self.configuration = configuration
        self.isSelected = isSelected
    }
}
