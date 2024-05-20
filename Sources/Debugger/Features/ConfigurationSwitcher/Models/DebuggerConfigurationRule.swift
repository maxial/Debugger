//
//  DebuggerConfigurationRule.swift
//
//
//  Created by Maxim Aliev on 20.04.2024.
//

import Foundation

enum DebuggerConfigurationRuleType: String, Identifiable, CaseIterable, Codable {
    var id: String { rawValue }
    
    case requestBody = "Request Body"
    case responseBody = "Response Body"
    
    var isRequestType: Bool { self == .requestBody }
    var isResponseType: Bool { self == .responseBody }
}

struct ConfigurationRuleParameter: Codable, Identifiable {
    public let id: UUID
    var key: String
    var value: AnyCodableParameter
}

public struct DebuggerConfigurationRule: Codable, Identifiable {
    public let id: UUID
    var type: DebuggerConfigurationRuleType
    var name: String = ""
    var path: String = ""
    var matchingParams: [ConfigurationRuleParameter] = []
    var updatingParams: [ConfigurationRuleParameter] = []
    var updatingResponse: String = ""
    var isEnabled = true
}
