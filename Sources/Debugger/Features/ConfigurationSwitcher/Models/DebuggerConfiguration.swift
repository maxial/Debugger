//
//  DebuggerConfiguration.swift
//
//
//  Created by Maxim Aliev on 27.03.2024.
//

import SwiftUI

struct DebuggerConfiguration: Identifiable {
    var id: String { name }
    
    let name: String
    let baseURL: URL
    
    @AppStorage private var customRulesData: String
    
    var customRules: [DebuggerConfigurationRule] {
        get {
            (try? JSONDecoder()
                .decode(
                    [DebuggerConfigurationRule].self,
                    from: Data(customRulesData.utf8)
                )
            ) ?? []
        }
        set {
            if let jsonData = try? JSONEncoder().encode(newValue) {
                customRulesData = String(data: jsonData, encoding: .utf8) ?? ""
            }
        }
    }
    
    init(name: String, baseURL: URL) {
        self.name = name
        self.baseURL = baseURL
        
        self._customRulesData = AppStorage(wrappedValue: "", "Debugger_Configuration_\(name)_CustomRules")
    }
}

extension DebuggerConfiguration: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
