//
//  ConfigurationViewModel.swift
//
//
//  Created by Maxim Aliev on 06.04.2024.
//

import SwiftUI

final class ConfigurationViewModel: ObservableObject {
    @Published var configuration: DebuggerConfiguration
    
    init(configuration: DebuggerConfiguration) {
        self.configuration = configuration
    }
    
    func update(rule: DebuggerConfigurationRule) {
        if let index = configuration.customRules.firstIndex(where: { $0.id == rule.id }) {
            configuration.customRules[index] = rule
        } else {
            configuration.customRules.append(rule)
        }
    }
    
    func removeCustomRules(at offsets: IndexSet) {
        configuration.customRules.remove(atOffsets: offsets)
    }
}
