//
//  ListRowModifier.swift
//
//
//  Created by Maxim Aliev on 19.03.2024.
//

import SwiftUI

struct ListRowModifier<Destination>: ViewModifier where Destination: View {
    private let outerInsets = EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
    private let innerInsets = EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
    
    private var isEditable: Bool
    private var destination: Destination
    private var backgroundColor: Color?
    private var isActive: Binding<Bool>?
    
    init(
        isEditable: Bool,
        destination: Destination,
        backgroundColor: Color? = nil,
        isActive: Binding<Bool>? = nil
    ) {
        self.isEditable = isEditable
        self.destination = destination
        self.backgroundColor = backgroundColor
        self.isActive = isActive
    }
    
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            itemView(content: content)
                .listRowInsets(
                    isEditable ? .zero :
                    EdgeInsets(
                        top: .zero,
                        leading: outerInsets.leading,
                        bottom: .zero,
                        trailing: outerInsets.trailing
                    )
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        } else {
            itemView(content: content)
                .listRowInsets(
                    isEditable ? .zero :
                    EdgeInsets(
                        top: .zero,
                        leading: outerInsets.leading,
                        bottom: .zero,
                        trailing: outerInsets.trailing
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
                RoundedRectangle(cornerRadius: isEditable ? .zero : 12)
                    .fill(backgroundColor ?? Color.secondarySystemGroupedBackground)
                
                HStack {
                    content
                        .padding(.leading, innerInsets.leading)
                        .padding(.trailing, Destination.self != EmptyView.self ? .zero : innerInsets.trailing)
                        .padding(.top, innerInsets.top)
                        .padding(.bottom, innerInsets.bottom)
                    
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
            .if(isEditable == false) { itemView in
                itemView
                    .padding(.top, outerInsets.top)
                    .padding(.bottom, outerInsets.bottom)
            }
        }
    }
}
