//
//  ListModifier.swift
//  
//
//  Created by Maxim Aliev on 24.03.2024.
//

import SwiftUI

struct ListModifier: ViewModifier {
    private var backgroundColor: Color?
    private var cornerRadius: CGFloat
    
    init(backgroundColor: Color? = nil, cornerRadius: CGFloat = .zero) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
    }
    
    func body(content: Content) -> some View {
        content
            .listStyle(.grouped)
            .background(backgroundColor ?? Color.systemGroupedBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
