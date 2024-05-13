//
//  AnyCodableParameter.swift
//
//
//  Created by Maxim Aliev on 29.04.2024.
//

import Foundation

public enum AnyCodableParameter: Codable, Identifiable {
    case int(Int)
    case string(String)
    
    public var id: String {
        switch self {
        case .int(let int):
            return int.description
        case .string(let string):
            return string
        }
    }
    
    public var value: String {
        get {
            switch self {
            case .int(let int):
                return int.description
            case .string(let string):
                return string
            }
        }
        set {
            switch self {
            case .int:
                self = .int(Int(newValue) ?? .zero)
            case .string:
                self = .string(newValue)
            }
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else {
            throw DecodingError.typeMismatch(
                AnyCodableParameter.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Incompatible Type")
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .int(let intValue):
            try container.encode(intValue)
        case .string(let stringValue):
            try container.encode(stringValue)
        }
    }
}
