//
//  ListRowModifier.swift
//
//
//  Created by Maxim Aliev on 24.03.2024.
//

import SwiftUI

struct ListRowModifier: ViewModifier {
    private enum Constants {
        static let defaultInsets = EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
    }
    
    private var backgroundColor: Color?
    
    init(backgroundColor: Color? = nil) {
        self.backgroundColor = backgroundColor
    }
    
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .listRowInsets(Constants.defaultInsets)
                .listRowSeparator(.hidden)
                .if(backgroundColor != nil) { $0.listRowBackground(backgroundColor) }
        } else {
            content
                .listRowInsets(Constants.defaultInsets)
                .if(backgroundColor != nil) { $0.listRowBackground(backgroundColor) }
        }
    }
}
