//
//  ConfigurationRuleViewModel.swift
//  
//
//  Created by Maxim Aliev on 20.04.2024.
//

import SwiftUI

final class ConfigurationRuleViewModel: ObservableObject {
    @Published var rule: DebuggerConfigurationRule
    
    init(rule: DebuggerConfigurationRule) {
        self.rule = rule
    }
}
