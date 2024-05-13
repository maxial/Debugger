//
//  EnvironmentValues+.swift
//
//
//  Created by Maxim Aliev on 15.03.2024.
//

import SwiftUI

private struct DebuggerKey: EnvironmentKey {
    static let defaultValue = Debugger()
}

extension EnvironmentValues {
    var debugger: Debugger {
        get { self[DebuggerKey.self] }
        set { self[DebuggerKey.self] = newValue }
    }
}
