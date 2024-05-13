//
//  ListNavigationRowModifier.swift
//
//
//  Created by Maxim Aliev on 19.03.2024.
//

import SwiftUI

struct ListNavigationRowModifier<Destination>: ViewModifier where Destination: View {
    private let defaultOuterInsets = EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
    private let defaultInnerInsets = EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
    
    private var backgroundColor: Color?
    private var destination: Destination
    private var isActive: Binding<Bool>?
    
    init(
        backgroundColor: Color? = nil,
        destination: Destination,
        isActive: Binding<Bool>? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.destination = destination
        self.isActive = isActive
    }
    
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            itemView(content: content)
                .listRowInsets(
                    EdgeInsets(
                        top: .zero,
                        leading: defaultOuterInsets.leading,
                        bottom: .zero,
                        trailing: defaultOuterInsets.trailing
                    )
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        } else {
            itemView(content: content)
                .listRowInsets(
                    EdgeInsets(
                        top: .zero,
                        leading: defaultOuterInsets.leading,
                        bottom: .zero,
                        trailing: defaultOuterInsets.trailing
                    )
                )
                .listRowBackground(Color.clear)
        }
    }
    
    private func itemView(content: Content) -> some View {
        ZStack {
            if Destination.self != EmptyView.self {
                if let isActive {
                    NavigationLink(destination: destination, isActive: isActive) {
                        EmptyView()
                    }
                    .opacity(.zero)
                } else {
                    NavigationLink(destination: destination) {
                        EmptyView()
                    }
                    .opacity(.zero)
                }
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor ?? Color.secondarySystemGroupedBackground)
                
                HStack {
                    content
                        .padding(.leading, defaultInnerInsets.leading)
                        .padding(.trailing, Destination.self != EmptyView.self ? 0 : defaultInnerInsets.trailing)
                        .padding(.top, defaultInnerInsets.top)
                        .padding(.bottom, defaultInnerInsets.bottom)
                    
                    if Destination.self != EmptyView.self {
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .resizable()
                            .frame(width: 7, height: 14)
                            .foregroundColor(.systemGray)
                            .padding(.trailing, 16)
                    }
                }
            }
            .padding(.top, defaultOuterInsets.top)
            .padding(.bottom, defaultOuterInsets.bottom)
        }
    }
}
