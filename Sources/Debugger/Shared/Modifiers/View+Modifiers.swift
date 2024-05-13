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
    
    func listRow(backgroundColor: Color? = nil) -> some View {
        modifier(ListRowModifier(backgroundColor: backgroundColor))
    }
    
    func listNavigationRow<Destination>(
        backgroundColor: Color? = nil,
        destination: Destination = EmptyView()
    ) -> some View where Destination: View {
        modifier(
            ListNavigationRowModifier(
                backgroundColor: backgroundColor,
                destination: destination
            )
        )
    }
    
    func listNavigationRow<Destination>(
        backgroundColor: Color? = nil,
        destination: Destination = EmptyView(),
        isActive: Binding<Bool>
    ) -> some View where Destination: View {
        modifier(
            ListNavigationRowModifier(
                backgroundColor: backgroundColor,
                destination: destination,
                isActive: isActive
            )
        )
    }
}
