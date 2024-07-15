//
//  File.swift
//  
//
//  Created by Maxim Aliev on 24.03.2024.
//

import SwiftUI

extension View {
    func list(backgroundColor: Color? = nil, cornerRadius: CGFloat = .zero) -> some View {
        modifier(ListModifier(backgroundColor: backgroundColor, cornerRadius: cornerRadius))
    }
    
    func listRow<Destination>(
        isEditable: Bool,
        destination: Destination = EmptyView(),
        backgroundColor: Color? = nil
    ) -> some View where Destination: View {
        modifier(
            ListRowModifier(
                isEditable: isEditable,
                destination: destination,
                backgroundColor: backgroundColor
            )
        )
    }
    
    func listRow<Destination>(
        isEditable: Bool,
        destination: Destination = EmptyView(),
        backgroundColor: Color? = nil,
        isActive: Binding<Bool>
    ) -> some View where Destination: View {
        modifier(
            ListRowModifier(
                isEditable: isEditable,
                destination: destination,
                backgroundColor: backgroundColor,
                isActive: isActive
            )
        )
    }
}
