//
//  Binding+.swift
//
//
//  Created by Maxim Aliev on 21.03.2024.
//

import SwiftUI

extension Binding {
    func onUpdate(_ closure: @escaping () -> Void) -> Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: {
                wrappedValue = $0
                closure()
            }
        )
    }
}
