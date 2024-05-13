//
//  DebuggerItemViewModel.swift
//
//
//  Created by Maxim Aliev on 07.04.2024.
//

import SwiftUI

final class DebuggerItemViewModel: ObservableObject {
    let type: DebugFeature
    let value: String
    
    init(type: DebugFeature, value: String) {
        self.type = type
        self.value = value
    }
}
