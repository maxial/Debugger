//
//  File.swift
//  
//
//  Created by Maxim Aliev on 23.03.2024.
//

import SwiftUI

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { }
}

extension View {
    var closeToolbarItem: ToolbarItem<(), Button<Text>> {
        ToolbarItem(placement: .confirmationAction) {
            Button(action: {
                Debugger.shared.hideDebugger()
            }, label: {
                Text("Close")
                    .foregroundColor(.systemBlue)
            })
        }
    }
    
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: @autoclosure () -> Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
}
